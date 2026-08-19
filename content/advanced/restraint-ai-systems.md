+++
title = "I build restraint open source AI systems: what they are, their limits, and their point"
date = 2026-08-03
weight = 19
authorship = "human-ai"
+++

Let's start with the word "restraint".

If I was a heavyweight wrestler, and a lightweight challenged me to a fight, and partway through I could see he was already tired and about to lose - I'm not tired, I could choose to keep beating him, show off, humiliate him. But I choose not to. That act of choosing not to, when I could, is restraint.

That is the exact idea I built into the systems I make.

## empathySync: the assistant that holds itself back

I wanted an AI assistant that would step back the moment I mention something sensitive - health, money, spirituality, that kind of thing. It can engage. The model underneath is perfectly capable of engaging. But I built it to step back. That's the important part: it isn't the machine deciding to be careful. I wired the holding-back in, because left alone it would happily talk all day.

On ordinary work it gives full help - writing code, breaking a topic down, the practical things. The restraint only kicks in on the sensitive ground. There it keeps its answers short, points you toward a real person, and refuses the little follow-up question designed to keep you talking. On the practical, it's a tool. On the personal, it gets out of your way.

You can read the full feature list, or run it yourself, on [GitHub](https://github.com/Olawoyin007/empathySync).

## intentKeeper: the filter that holds the feed back

intentKeeper is the same idea, aimed the other way. empathySync holds itself back. intentKeeper holds the feed back.

It's a browser add-on for Twitter, YouTube, and Reddit. As you scroll, it flags the posts that are trying to work you - ragebait, fearmongering, hype, the divisive stuff. It doesn't care what the post is about. It watches what the post is doing to you. It marks that before the post lands, and then it gets out of the way and lets you decide what to open. Same as everything I build, it runs on your machine and sends nothing out.

It's on [GitHub](https://github.com/Olawoyin007/intentKeeper) if you want to run it.

## The limits, honestly

Neither of these is a wall. They lower the odds; they don't promise anything.

empathySync reads your message with two layers, one fast and one context-aware, but no list of harmful phrasings is ever complete. A message worded cleverly enough can slip past both. intentKeeper is right most of the time, not all of the time, and the ones it misses are usually the hard boundary cases - an alarming fact that happens to be true and fairly stated. Both projects say this out loud in their own docs, because a safety tool that oversells itself is worse than no tool at all. These reduce harm. They don't remove it.

## Why I build them anyway

I've come to realise I have a passion for building AI systems whose whole goal is to make you need them less.

Which is a strange thing to build. It isn't profitable - a tool designed to make you leave doesn't grow its numbers, doesn't keep you scrolling, doesn't have a reason to want your time. In one light it's a little crazy. But that's exactly the point, and empathySync's own line says it better than I can: the goal isn't a better chatbot, it's a world where you need chatbots less.

That's the restraint. Not a machine that learned to be humble. A person who built the holding-back in on purpose, because he thinks that's the kind of AI worth having.
