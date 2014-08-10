#!/usr/bin/perl


##TODO: integrate this with grocess, replace s/<sc>// with regular expression with <sc\b[^>]*>(.*?)</sc>
##	ensure newline between each entry in main file
##	then start typesetting Psalms :)

use strict;
use IO::File;


#usage gprP <Psalm> <tone>
my $GABCFILE = $ARGV[0];
my $TONE = $ARGV[1];

if ($GABCFILE !~ m#\.mgabc#) {
   die "File extension must be mgabc: $GABCFILE\n";
};

if ($#ARGV < 1) {
  die "usage: $0 <mgabc-file-name> <tone>\n";
}

my $GABCOUT = $GABCFILE;
my $GABCOUT2 = $GABCFILE;

my $GABCNAME = $GABCFILE;
  $GABCNAME =~ s/.gabc$//;
my $GABCSCORES = $GABCFILE;
  $GABCSCORES =~ s/.gabc/scores.txt/;
my $TEXT;
my $KEEPSEARCHING = 1;
my $INLINE = "";
my $SCCOUNT = 0;
my $TXCOUNT = 0;

my $SCORENAME;

my $GABCFILES = $GABCFILE;
$GABCFILES =~ s/.gabc/full.$TONE.tex/;


## Remove previous temp file
system ("rm ./temp.tex");

## Create new temp file
my $TEMPFILE = "./temp.tex";
my $TEMPFILE2 = "./temp2.tex";

## insert headers to temp
open (OUTPUTTEMP,">>".$TEMPFILE);

## Read in the template
my @TEMPLATELINES;

@TEMPLATELINES = <DATA>;

## Name of the Score
open (GABC,"<".$GABCFILE) or die "No such file: $GABCFILE\n";
$INLINE = <GABC>;
if ($INLINE =~ /^name/) {
    $SCORENAME = $INLINE;
    $SCORENAME =~ s/^.*:\s*//;
    $SCORENAME =~ s/\s*;\s*$//;
}



&do_subst ("XXXX-GABCFILES-XXXX", $GABCFILES);
&do_subst ("XXXX-SCORENAME-XXXX", $SCORENAME);

## Create main wrapper
my $WRAPPER = $GABCFILE;
$WRAPPER =~ s/.gabc$/main.$TONE.tex/;

my $PDFOUTPUT = $WRAPPER;
$PDFOUTPUT =~ s/tex$/pdf/;

open (TEXWRAP,">".$WRAPPER) or die "Cannot write file $WRAPPER\n";
print TEXWRAP @TEMPLATELINES;
close (TEXWRAP);


## Split original gabc, add references in temp
open (GABC,"<".$GABCFILE) or die "No such file: $GABCFILE\n";
open (SCORES,">>".$GABCSCORES);
while ($KEEPSEARCHING == 1 && ($INLINE = <GABC>)) {
# if inline = tx or sc
  if ($INLINE =~ m/<sc>(.*?)<\/sc>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<sc>//;
  $TEXT =~ s/<\/sc>//;
  $SCCOUNT = $SCCOUNT + 1;
  $GABCOUT =~ s/.gabc$/$SCCOUNT.gabc/;
  print "$GABCOUT\n";
  print "$INLINE";
#  print "$SCCOUNT\n";
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (OUTPUT,">".$GABCOUT);
  print OUTPUT "name:;\n";
#  print OUTPUT "centering-scheme:english;\n";
  print OUTPUT "%%\n";
  print OUTPUT "$TEXT";
  print SCORES "$SCCOUNT: $TEXT";
  system ("gregorio $GABCOUT");
  system ("/home/ahinkley/gprocess_eps_quiet $GABCNAME$SCCOUNT 4.5");
  $GABCOUT =~ s/.gabc$/.tex/;
  print OUTPUTTEMP "\\includescore\{$GABCOUT\}\n";
  $INLINE =~ s/<sc>(.*?)<\/sc>//;
  close (OUTPUT);
  close (OUTPUTTEMP);

  $GABCOUT = $GABCFILE;

  }
if ($INLINE =~ m/<tx>(.*?)<\/tx>/) {
  $TEXT = $INLINE;
  $TEXT =~ s/<tx>//;
  $TEXT =~ s/<\/tx>//;
  open (OUTPUTTEMP,">>".$TEMPFILE);
  print OUTPUTTEMP "$TEXT\n";
  $INLINE =~ s/<tx>(.*?)<\/tx>//;
  close (OUTPUTTEMP);
  }
if ($INLINE =~ m/<ps>(.*?)<\/ps>/) {	#Psalm Score: output to .tone, create name_tone.gabc
  $TEXT = $INLINE;
  $TEXT =~ s/<ps>/(\\key)(\\x)/;
  $TEXT =~ s/<\/ps>//;
#  $TEXT =~ s/{\\bf/ <b>/;
#  $TEXT =~ s/}/. <\/b>/;
#red text
  $TEXT =~ s/{\\bf/ <v>\\red{\\bf /;
  $TEXT =~ s/}/. }<\/v>/;
  $TEXT =~ s/\*/<v>\\red\{*\}<\/v>/g;
  $TEXT =~ s/\+/<v>\\red\{+\}<\/v>/g;
print $TEXT;
  $SCCOUNT = $SCCOUNT + 1;
  $GABCOUT =~ s/.gabc$/$SCCOUNT.tone/;
  $GABCOUT2 =~ s/.gabc$/$SCCOUNT-$TONE.gabc/;
  print "$GABCOUT\n";
  print "$GABCOUT2\n";
  print "$INLINE";
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (OUTPUT,">".$GABCOUT);
  print OUTPUT "name:;\n";
  print OUTPUT "%%\n";
  print OUTPUT "$TEXT\n";
  print SCORES "$SCCOUNT: $TEXT";
# Convert Tone code to gabc code
  system ("sed $GABCOUT -f /iomega/Psalmtones/$TONE.sed > $GABCOUT2");
  system ("gregorio $GABCOUT2");
#copy to draft
  system("cp $GABCOUT2 draft/");
#  system ("/home/ahinkley/gprocess_eps_quiet $GABCNAME$SCCOUNT 4.5");
  system ("/home/ahinkley/gprocess_eps_quiet $GABCNAME$SCCOUNT 4.5");
  $GABCOUT2 =~ s/.gabc$/.tex/;
  print OUTPUTTEMP "\\includescore\{$GABCOUT2\}\n";
  $INLINE =~ s/<ps>(.*?)<\/ps>//;
  close (OUTPUT);
  close (OUTPUTTEMP);

#reset variables
  $GABCOUT = $GABCFILE;
  $GABCOUT2 = $GABCFILE;

  }
if ($INLINE =~ m/<pt>(.*?)<\/pt>/) {	#Psalm Text: output to temp, sed psalmtext, append to file
  $TEXT = $INLINE;
  $TEXT =~ s/<pt>//;
  $TEXT =~ s/<\/pt>//;
#red text for asterisks, verse numbers
  $TEXT =~ s/({\\bf [0-9]+})/\\red{$1.}/g;
  $TEXT =~ s/\*/\\red{*}/g;
  $TEXT =~ s/\+/\\red{+}/g;
#  $TEXT =~ s/\$\\dag\$/\\red{\$\\dag\$}/g;
  $TEXT =~  s/\(\\f\)([^\s]*)\s/$1 \\red{\$\\dag\$} /;
  $TEXT =~ s/\[fit reverentia\]/\\red{[fit reverentia]}/g;
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (OUTPUTTEMP2,">".$TEMPFILE2);
  print OUTPUTTEMP2 "$TEXT\n";
  system ("sed -f /iomega/Psalmtones/textcodes/text$TONE.sed $TEMPFILE2 >> $TEMPFILE");
  $INLINE =~ s/<pt>(.*?)<\/pt>//;
  close (OUTPUTTEMP);
  }

if ($INLINE =~ m/<pf>(.*?)<\/pf>/) {	#Psalm Text: output to temp, sed psalmtext, append to file
  $TEXT = $INLINE;
  $TEXT =~ s/<pf>//;
  $TEXT =~ s/<\/pf>//;
#red text for asterisks, verse numbers
  $TEXT =~ s/({\\bf [0-9]+})/\\red{$1.}/g;
  $TEXT =~ s/\*/\\red{*}/g;
  $TEXT =~ s/\+/\\red{+}/g;
  $TEXT =~ s/\\dag/\\red{\\dag}/g;
  $TEXT =~ s/\[fit reverentia\]/\\red{[fit reverentia]}/g;
  $TEXT =~ s/(}\s\w*)/\U$1/;
  $TEXT =~ s/}\s(\w)/} \\red{\\Huge{$1}}/;
  open (OUTPUTTEMP,">>".$TEMPFILE);
  open (OUTPUTTEMP2,">".$TEMPFILE2);
  print OUTPUTTEMP2 "$TEXT\n";
  system ("sed -f /iomega/Psalmtones/textcodes/text$TONE.sed $TEMPFILE2 >> $TEMPFILE");
  $INLINE =~ s/<pf>(.*?)<\/pf>//;
  close (OUTPUTTEMP);
  }



#if ($INLINE =~ m/[^<]/) {
#  $TEXT = $INLINE;
#  open (OUTPUTTEMP,">>".$TEMPFILE);
#  print OUTPUTTEMP "$TEXT\\par\n";
#  $INLINE =~ s/(.*?)//;
#  close (OUTPUTTEMP);
#  }

#  if ($INLINE =~ /^%%/) { $KEEPSEARCHING = 0; }
}
system ("gprocess_lua $GABCFILE");

close (GABC);

open (TEXWRAP,">".$WRAPPER) or die "Cannot write file $WRAPPER\n";
print TEXWRAP @TEMPLATELINES;
close (TEXWRAP);

##Rename temp file

system("mv $TEMPFILE $GABCFILES");
system("lualatex $WRAPPER");
#system("mv $PDFOUTPUTSHORT $PDFOUTPUT");
system("xpdf -cont -g 1000x250+280+575 -z 200 $PDFOUTPUT");
#copy files to draft
system("cp $GABCFILES draft/");

## Make substitution in template
sub do_subst {
  my $TAG = $_[0];
  my $VAL = $_[1];

  foreach (@TEMPLATELINES) {
     s/$TAG/$VAL/g;
  }
};



#  THE LINES AFTER THIS "END" TAG ARE A TEMPLATE FOR THE TEX FILE TO BE GENERATED
__END__

\documentclass[10pt, letterpaper]{article}
\usepackage{fullpage}
\usepackage{palatino}
\usepackage{color}
\usepackage[T1]{fontenc}
\usepackage[utf8]{luainputenc}
\usepackage{gregoriotex}
\usepackage{longtable}
\usepackage{color}
\pagestyle{empty}
\setlength{\paperwidth}{6.0in} 
\setlength{\paperheight}{9.0in}
\setlength{\textwidth}{4.5in}
\begin{document}
\newcommand{\cent}[1]{\begin{center}{#1}\end{center}}
\newcommand{\red}[1]{\textcolor{red}{#1}}

%\setspaceafterinitial{3.2mm plus 0em minus 0em}
%\setspacebeforeinitial{3.2mm plus 0em minus 0em}

\def\greinitialformat#1{%
{\fontsize{23}{23}\selectfont #1}%
}

\setgrefactor{13}
\grespaceabovelines=4mm

\begin{center}\begin{huge}\textsc{XXXX-SCORENAME-XXXX}\end{huge}\end{center}

\includescore{XXXX-GABCFILES-XXXX}

\end{document}


