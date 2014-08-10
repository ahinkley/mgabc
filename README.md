MGABC, or "Master GABC" (as in master document) is a Perl script based on gprocess to create books/booklets from Gregorio, LilyPond and LaTeX files.

The script reads off lines one by one, and checks the HTML tag, processes them, then adds them to the output tex file for separate compilation.

The tags are as follows:
sc: Insert raw GABC code.
Usage: <sc> GABC code </sc>

g3: gabc with {init1}{init2}{commentary}
Usage: 

g3e: gabc with {init1}{init2}{commentary} and English spacing.
Usage:

sl: Score with Latin spacing.
Usage:

ft: Include external tex file.
Usage:

fi: Include external tex file, use fancy Initial.
Usage:

fj: Include external tex file with Gothic Initial.
Usage:

ff: Include external file.
Usage: <ff>FILENAME</ff>

fa: Antiphon with additional annotation above Initial.
Usage: <fa>FILENAME</fa>ANNOTATION

fb: Override both lines of annotation.
Usage:

tx: Insert raw LaTeX code (deprecated)
Usage:
