# keynote-extractor

> 🎁 Extract Keynote presentations to JSON and Markdown using a simple script.

# What it does

You can use this script to take a Keynote presentation and build a JSON representation of it that looks like this:

```json
[{
  "title": "Slide 1",
  "slide": "keynote-modular-design.001.png",
  "notes": "Hey everyone!\u000aToday I\u2019m going to speak about Modular Design."
},
  ...
]
```

This is useful if you prepare your slides using Presenter Notes, and write them in such a way that you could then create blog posts with pretty much the same contents.

# Compilation

Compile both scripts from source:

```shell
osacompile -o json.scpt json.applescript
osacompile -o keynote-extractor.scpt keynote-extractor.applescript
```

# Usage

Open your presentation in Keynote. Then, open `keynote-extractor.scpt` with Script Editor. The JSON file, a README and an image for each slide will be placed in a folder like `~/Desktop/keynote-$PRESENTATION_TITLE`.

# License

MIT
