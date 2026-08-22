# Supported ABC grammar

`moonbit-abc` is a source-aware parser for a practical, deliberately bounded subset of ABC notation. The parser preserves source spans and retains unknown input as raw nodes so callers can diagnose or extend it without silently losing text.

## Headers

The parser recognizes the common record fields `X`, `T`, `M`, `L`, `K`, `V`, `w`, and `W`. Repeated title, voice, lyric, and text fields are retained in source order. Unknown one-letter fields are preserved as header fields and remain available through the document query API.

## Music items

The structured music model includes:

- pitched notes, accidentals, octave marks, and duration fractions;
- rests, bar lines, repeat starts and ends;
- bracketed chords, decorations, ornaments, tuplets, ties, slurs, and grace groups;
- inline fields, comments, `%%` directives, and voice switches;
- lyrics associated with the source record.

## Semantic checks

Validation reports missing `X`/`K` fields, invalid meters and keys, duplicate voices, malformed notes and chords, unmatched repeats, unsupported raw syntax, and selected measure, voice, and lyric quality issues. Diagnostics retain line, column, and source span information.

## Output contract

`to_json` emits schema v1 JSON. `pretty_print` and `format_document` produce deterministic ABC text. New analysis helpers are additive and do not change existing schema v1 fields.

## Deliberate non-goals

The package does not implement MIDI playback, audio rendering, MusicXML conversion, macro expansion, or every advanced ABC extension. Unsupported syntax is retained and reported rather than discarded. These boundaries keep the core library suitable for catalog import, teaching tools, editor diagnostics, and further incremental extension.
