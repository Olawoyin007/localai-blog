+++
title = "Choosing a quantization: Q4, Q6, or Q8"
date = 2026-07-22
authorship = "human-ai"
+++

Quantizing a model is like saving a photo at a smaller file size. You drop a little detail to save a lot of space, and it runs faster. The number - Q4, Q6, Q8 - is roughly how much detail is kept.

A simple way to choose:

- **Q4** - smallest and fastest. The sensible default when memory is tight.
- **Q6** - a middle ground. A little sharper, still light.
- **Q8** - keeps the most precision. Worth it only when you have memory to spare and want the best answers.

With Ollama you just ask for the one you want:

```bash
# pick the size you want - q4 is smallest, q8 keeps the most detail
ollama run qwen3.5:q4

# or point your own code at the model
curl http://localhost:11434/api/generate \
  -d '{"model": "qwen3.5:q4", "prompt": "hello"}'
```

My advice: start at Q4. Only move up if you can feel the model getting answers wrong in a way that matters to you. Most of the time, you cannot.
