import 'package:flutter_test/flutter_test.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/features/sessions/session_chat_screen.dart';

/// Regression coverage for "the transcript drifts / jitters under the user
/// while a reply streams in".
///
/// History, because it explains why the fix lives where it does. The message
/// list renders `reverse: true`, so the newest message is index 0 at scroll
/// offset 0 and older messages occupy increasing offsets — pin detection is
/// therefore "close to zero", the *opposite* of the usual `maxScrollExtent`
/// convention.
///
///  * Attempt 1 compensated the user's `pixels` by the frame-over-frame
///    delta of `ScrollPosition.maxScrollExtent`. On a lazily-built
///    `ListView.builder` that value is an *estimate* over whatever children
///    have been laid out so far and moves purely from scrolling into
///    not-yet-built items. Scrolling up fed the compensation and the list
///    became nearly unscrollable.
///  * Attempt 2 fixed the *signal* — measuring the streaming bubble's real
///    `RenderBox` height — but kept the shape: correct the offset from a
///    post-frame callback. That is structurally jittery. Every token
///    composites one frame with the content in the wrong place and then
///    `jumpTo`s it back, so at streaming rates the text visibly glitches up
///    and down. No better delta measurement can fix a reactive correction.
///  * Attempt 3 sidestepped the jitter by *freezing* the rendered transcript
///    while the user was scrolled up mid-stream, buffering deltas until they
///    re-pinned. No jitter, but the transcript stopped updating while you
///    read it — worse than mainstream chat apps.
///
/// The current design instead adopts `scrollview_observer`'s
/// `ChatScrollObserver` / `ChatObserverClampingScrollPhysics`, which override
/// `ScrollPhysics.adjustPositionForNewDimensions` — called by
/// `ScrollPosition.applyContentDimensions` *during layout* — so a corrected
/// scroll offset lands in the same frame the content grew. Nothing wrong is
/// ever painted, and the transcript always renders the live message list; see
/// `SessionChatScreenState._chatObserver` and its `standby()` call sites in
/// `session_chat_screen.dart` for the wiring. That machinery is the
/// package's, not this app's, so it is exercised by `flutter test`'s widget
/// tests / manual verification rather than a pure-function unit test here.
///
/// What remains as this screen's *own* pure decision surface — and what this
/// file covers — is [isPinnedToBottom] (pin/unpin threshold for the
/// jump-to-latest affordance), [isUnansweredUserAt] (the "No response yet" +
/// Resend/Edit chip logic), [sameRenderedTranscript] and
/// [classifyWholesaleReplace] (whether/how a background resync — reload
/// button, initial `_load`, or the debounced `tool.start`/`tool.complete`
/// resync in `gateway_realtime.dart` — needs to brief `ChatScrollObserver`
/// before it lands; see the classification comment above the `_messages`
/// field in `session_chat_screen.dart` for the full audit of every
/// `_messages` mutation site).
void main() {
  group('latestModelSwitchMarkerId', () {
    test('returns the newest durable marker and ignores ordinary messages', () {
      expect(
        latestModelSwitchMarkerId([
          const HermesMessage(id: 'ordinary', sessionId: 's', role: 'user'),
          const HermesMessage(
            id: 'old-switch',
            sessionId: 's',
            role: 'user',
            displayKind: 'model_switch',
          ),
          const HermesMessage(
            id: 'assistant',
            sessionId: 's',
            role: 'assistant',
          ),
          const HermesMessage(
            id: 'new-switch',
            sessionId: 's',
            role: 'user',
            displayKind: 'model_switch',
          ),
        ]),
        'new-switch',
      );
    });

    test('returns null when reconnect history has no model switch', () {
      expect(
        latestModelSwitchMarkerId([
          const HermesMessage(id: 'ordinary', sessionId: 's', role: 'user'),
        ]),
        isNull,
      );
    });
  });

  group('isPinnedToBottom', () {
    test('exactly at the newest-message anchor (offset 0) is pinned', () {
      expect(isPinnedToBottom(0), isTrue);
    });

    test('within the small tolerance band still counts as pinned', () {
      expect(isPinnedToBottom(kAutoscrollPinThresholdPx), isTrue);
      expect(isPinnedToBottom(kAutoscrollPinThresholdPx - 1), isTrue);
    });

    test('past the tolerance — user has deliberately scrolled up — unpins', () {
      expect(isPinnedToBottom(kAutoscrollPinThresholdPx + 1), isFalse);
    });

    test('far up in a long, generated message stays unpinned', () {
      expect(isPinnedToBottom(4200), isFalse);
    });

    test('a custom threshold is honored', () {
      expect(isPinnedToBottom(50, threshold: 40), isFalse);
      expect(isPinnedToBottom(30, threshold: 40), isTrue);
    });
  });

  /// The observer's hold and the screen's pin detection are two halves of one
  /// behaviour, wired through two different numbers. They shipped disagreeing
  /// (`fixedPositionOffset = 5` against a 96px threshold) and the gap between
  /// them was a state with no exit: the observer pinned the reading position,
  /// so the streaming reply stopped advancing, while `isPinnedToBottom` still
  /// said "pinned", so the jump-to-latest chip was withheld. Nudging the list
  /// ~50px mid-stream was enough to get there.
  group('the observer hold and the jump-to-latest chip agree', () {
    test('the two constants are the same number', () {
      expect(kChatObserverFixedPositionOffset, kAutoscrollPinThresholdPx);
    });

    test('no offset both holds the position and hides the chip', () {
      // `ChatObserverScrollPhysicsMixin.adjustPositionForNewDimensions` skips
      // its correction when `newPosition.extentBefore <= fixedPositionOffset`,
      // and the list is `reverse: true`, so `extentBefore == pixels`. "Held"
      // must therefore be exactly "not pinned", at every offset.
      for (var px = 0.0; px <= 400; px += 0.5) {
        expect(
          chatObserverHoldsPositionAt(px),
          !isPinnedToBottom(px),
          reason: 'offset $px',
        );
      }
    });

    test('the old 5px offset reproduces the dead zone', () {
      // Guards the direction of the fix: with the shipped pair, a 50px nudge
      // froze the transcript *and* withheld the chip.
      expect(chatObserverHoldsPositionAt(50, fixedPositionOffset: 5), isTrue);
      expect(isPinnedToBottom(50), isTrue);
      // Aligned, the same offset keeps following the stream instead.
      expect(chatObserverHoldsPositionAt(50), isFalse);
    });

    test('past the threshold the observer holds and the chip is offered', () {
      expect(isPinnedToBottom(kAutoscrollPinThresholdPx + 1), isFalse);
      expect(
        chatObserverHoldsPositionAt(kAutoscrollPinThresholdPx + 1),
        isTrue,
      );
      // And at the boundary itself, both still say "following".
      expect(isPinnedToBottom(kAutoscrollPinThresholdPx), isTrue);
      expect(chatObserverHoldsPositionAt(kAutoscrollPinThresholdPx), isFalse);
    });
  });

  group('isUnansweredUserAt', () {
    HermesMessage user(String id, {String? displayKind}) => HermesMessage(
      id: id,
      sessionId: 's1',
      role: 'user',
      content: 'q',
      displayKind: displayKind,
    );
    HermesMessage assistant(
      String id,
      String content, {
      String? finishReason,
    }) => HermesMessage(
      id: id,
      sessionId: 's1',
      role: 'assistant',
      content: content,
      finishReason: finishReason,
    );

    test('out-of-range and non-user indices are false', () {
      final messages = [user('u1'), assistant('a1', 'hi')];
      expect(isUnansweredUserAt(messages, -1, sending: false), isFalse);
      expect(isUnansweredUserAt(messages, 9, sending: false), isFalse);
      expect(isUnansweredUserAt(messages, 1, sending: false), isFalse);
    });

    test('answered turn is not unanswered', () {
      final messages = [user('u1'), assistant('a1', 'here you go')];
      expect(isUnansweredUserAt(messages, 0, sending: false), isFalse);
    });

    test(
      'trailing user turn with nothing after it is unanswered when idle',
      () {
        expect(isUnansweredUserAt([user('u1')], 0, sending: false), isTrue);
      },
    );

    test(
      '…but NOT while the turn is in flight — it is waiting, not failed',
      () {
        expect(isUnansweredUserAt([user('u1')], 0, sending: true), isFalse);
      },
    );

    test('REGRESSION: `sending` alone flips the answer — callers must pass '
        'the flag that matches the state their render pass used', () {
      // This is a height change (a "No response yet" label plus Resend/Edit
      // chips appear). The function stays pure/parameterized specifically so
      // callers can't accidentally derive it from stale state.
      final messages = [user('u1')];
      expect(
        isUnansweredUserAt(messages, 0, sending: true),
        isNot(isUnansweredUserAt(messages, 0, sending: false)),
      );
    });

    test('an earlier turn is still judged normally while a later one is in '
        'flight', () {
      final messages = [user('u1'), user('u2')];
      expect(isUnansweredUserAt(messages, 0, sending: true), isTrue);
      expect(isUnansweredUserAt(messages, 1, sending: true), isFalse);
    });

    test('an error reply counts as unanswered', () {
      final messages = [
        user('u1'),
        assistant('a1', 'nope', finishReason: 'error'),
      ];
      expect(isUnansweredUserAt(messages, 0, sending: false), isTrue);
    });

    test('empty assistant rows are skipped, tool/system rows are not '
        'turn boundaries', () {
      final messages = [
        user('u1'),
        assistant('a0', ''),
        HermesMessage(
          id: 't1',
          sessionId: 's1',
          role: 'tool',
          content: 'ran',
          toolName: 'bash',
        ),
        HermesMessage(id: 's2', sessionId: 's1', role: 'system', content: 'x'),
        assistant('a1', 'the real reply'),
      ];
      expect(isUnansweredUserAt(messages, 0, sending: false), isFalse);
    });

    test('a synthetic user-role marker is neither a turn nor a boundary', () {
      final marker = user('m1', displayKind: 'model_switch');
      expect(isUnansweredUserAt([marker], 0, sending: false), isFalse);
      final messages = [user('u1'), marker, assistant('a1', 'reply')];
      expect(isUnansweredUserAt(messages, 0, sending: false), isFalse);
    });
  });

  group('sameRenderedTranscript', () {
    HermesMessage msg(
      String id, {
      String role = 'assistant',
      String? content,
      String? toolName,
      String? finishReason,
      String? displayKind,
      String? timestamp,
      int? tokenCount,
      String? reasoning,
    }) => HermesMessage(
      id: id,
      sessionId: 's1',
      role: role,
      content: content,
      toolName: toolName,
      finishReason: finishReason,
      displayKind: displayKind,
      timestamp: timestamp,
      tokenCount: tokenCount,
      reasoning: reasoning,
    );

    test('identical list instance is trivially the same', () {
      final list = [msg('a', content: 'x')];
      expect(sameRenderedTranscript(list, list), isTrue);
    });

    test('equal-by-value copies are the same', () {
      expect(
        sameRenderedTranscript(
          [msg('a', content: 'x')],
          [msg('a', content: 'x')],
        ),
        isTrue,
      );
    });

    test('different lengths are never the same', () {
      expect(
        sameRenderedTranscript(
          [msg('a', content: 'x')],
          [msg('a', content: 'x'), msg('b', content: 'y')],
        ),
        isFalse,
      );
    });

    test('an id swap (optimistic → server id) is a difference', () {
      expect(
        sameRenderedTranscript(
          [msg('local_user_1', content: 'hi')],
          [msg('srv_9', content: 'hi')],
        ),
        isFalse,
      );
    });

    test('a content difference is caught', () {
      expect(
        sameRenderedTranscript(
          [msg('a', content: 'The')],
          [msg('a', content: 'The parser reads')],
        ),
        isFalse,
      );
    });

    test('role, tool name, finish reason, and display kind are all '
        'compared', () {
      expect(
        sameRenderedTranscript(
          [msg('a', role: 'user')],
          [msg('a', role: 'assistant')],
        ),
        isFalse,
      );
      expect(
        sameRenderedTranscript(
          [msg('a', toolName: 'bash')],
          [msg('a', toolName: 'python')],
        ),
        isFalse,
      );
      expect(
        sameRenderedTranscript(
          [msg('a', finishReason: 'stop')],
          [msg('a', finishReason: 'error')],
        ),
        isFalse,
      );
      expect(
        sameRenderedTranscript(
          [msg('a', displayKind: null)],
          [msg('a', displayKind: 'model_switch')],
        ),
        isFalse,
      );
    });

    test('REGRESSION: fields the bubble does not render — timestamp, token '
        'count, reasoning — are deliberately NOT compared, so a resync that '
        'only refreshes those still counts as unchanged (a missed '
        'optimization would be a correctness bug the other way around, but '
        'this direction only costs a skipped setState)', () {
      expect(
        sameRenderedTranscript(
          [
            msg(
              'a',
              content: 'x',
              timestamp: '2020-01-01T00:00:00Z',
              tokenCount: 1,
              reasoning: 'r1',
            ),
          ],
          [
            msg(
              'a',
              content: 'x',
              timestamp: '2020-06-01T00:00:00Z',
              tokenCount: 99,
              reasoning: 'r2',
            ),
          ],
        ),
        isTrue,
      );
    });

    test('null content is not confused with empty content', () {
      final withNull = HermesMessage(id: 'a', sessionId: 's1', role: 'user');
      final withEmpty = HermesMessage(
        id: 'a',
        sessionId: 's1',
        role: 'user',
        content: '',
      );
      expect(sameRenderedTranscript([withNull], [withEmpty]), isFalse);
    });

    test('empty on both sides', () {
      expect(sameRenderedTranscript(const [], const []), isTrue);
    });
  });

  group('classifyWholesaleReplace', () {
    test('growth reports insertAtHead — every source that grows _messages '
        'appends at the chronological end, which is visual index 0 in the '
        'reversed list', () {
      expect(
        classifyWholesaleReplace(oldLength: 3, newLength: 4),
        WholesaleReplaceMode.insertAtHead,
      );
      expect(
        classifyWholesaleReplace(oldLength: 0, newLength: 12),
        WholesaleReplaceMode.insertAtHead,
      );
    });

    test('shrinkage reports remove — which message(s) vanished is not '
        'knowable from a count alone, so this defers to the platform '
        "default rather than guess", () {
      expect(
        classifyWholesaleReplace(oldLength: 5, newLength: 2),
        WholesaleReplaceMode.remove,
      );
    });

    test('an unchanged length reports none — nothing has a new '
        'layoutOffset to correct', () {
      expect(
        classifyWholesaleReplace(oldLength: 4, newLength: 4),
        WholesaleReplaceMode.none,
      );
      expect(
        classifyWholesaleReplace(oldLength: 0, newLength: 0),
        WholesaleReplaceMode.none,
      );
    });
  });
}
