<<<<<<< HEAD
#!/usr/bin/perl -w
# Copyright (c) 1998 Michael Zucchi, All Rights Reserved
# Copyright (C) 2000, 1  Tim Waugh <twaugh@redhat.com>
# Copyright (C) 2001  Simon Huggins
# Copyright (C) 2005-2012  Randy Dunlap
# Copyright (C) 2012  Dan Luedtke
#
# #define enhancements by Armin Kuster <akuster@mvista.com>
# Copyright (c) 2000 MontaVista Software, Inc.
#
# This software falls under the GNU General Public License.

use strict;
use warnings;
use diagnostics;

=======
#!/usr/bin/env perl

use strict;
use warnings;
>>>>>>> master
use File::Basename;
use Cwd 'abs_path';
use Term::ANSIColor qw(:constants);
use Getopt::Long qw(:config no_auto_abbrev);

my $P = $0;
my $D = dirname(abs_path($P));
my $V = '2.0.0';
my $min_perl_version = 5.10.0;

my $verbose = 0;
my $brief = 0;
my $help = 0;
my $version = 0;
my $color = 1;

# version subroutine
# $exitcode (optional): Exit status (default 0)
#
# Prints out informations about the script and exit
sub version {
	my $exitcode = shift @_ || 0;

	print STDOUT "Betty documentation style checker\n";
	print STDOUT "Version: $V\n";
	exit($exitcode);
}

# help subroutine
# $exitcode (optional): Exit status (default 0)
#
# Prints out a help message on how to use the script and exit
sub help {
	my $exitcode = shift @_ || 0;

	print << "EOM";
Usage: $P [OPTION]... FILE...
Options:
  --verbose                       Verbose mode
  -b, --brief                     Brief mode. One line per warning. No summary
  --no-color                      Use colors when output is STDOUT (default: on)

<<<<<<< HEAD
  -h, --help                      Display this help and exit
  -v, --version                   Display the version of the srcipt
=======
# 25/07/2012 - Added support for HTML5
# -- Dan Luedtke <mail@danrl.de>

my $V = '1.0';
my $P = $0;

sub printVersion {

	print STDOUT << "EOM";
Version: $V
>>>>>>> master
EOM
	exit($exitcode);
}

GetOptions(
	'verbose'	=> \$verbose,
	'b|brief'	=> \$brief,
	'color!'	=> \$color,
	'h|help'	=> \$help,
	'v|version'	=> \$version
) or help(1);
help(0) if ($help);
version(0) if ($version);

<<<<<<< HEAD
if ($^V && $^V lt $min_perl_version) {
	printf "$P: requires at least perl version %vd\n", $min_perl_version;
	exit(1);
=======
Read C language source or header FILEs, extract embedded documentation comments,
and print STDOUT formatted documentation to standard output.

The documentation comments are identified by "/**" opening comment mark. See
Documentation/kernel-doc-nano-HOWTO.txt for the documentation comment syntax.

Output format selection (mutually exclusive):
  -docbook		Output DocBook format.
  -html			Output HTML format.
  -html5		Output HTML5 format.
  -list			Output symbol list format. This is the default.
  -man			Output troff manual page format.
  -rst			Output reStructuredText format.
  -text			Output plain text format.

Output selection (mutually exclusive):
  -function NAME	Only output documentation for the given function(s)
			or DOC: section title(s). All other functions and DOC:
			sections are ignored. May be specified multiple times.
  -nofunction NAME	Do NOT output documentation for the given function(s);
			only output documentation for the other functions and
			DOC: sections. May be specified multiple times.

Output selection modifiers:
  -no-doc-sections	Do not output DOC: sections.

Other parameters:
  -v			Verbose output, more warnings and other information.
  -h			print STDOUT this help.
  -r                    Run for every C source file (.c and .h) recursively

EOF
    print STDOUT $message;
    exit 1;
>>>>>>> master
}

if ($#ARGV < 0) {
	my $exec_name = basename($P);
	print "$exec_name: no input files\n";
	print "Run '$exec_name --help' for usage\n";
	exit(1);
}

## init lots of data
my $anon_struct_union = 0;

# match expressions used to find embedded type information
my $type_constant = '\%([-_\w]+)';
my $type_func = '(\w+)\(\)';
my $type_param = '\@(\w+)';
my $type_struct = '\&((struct\s*)*[_\w]+)';

# list mode
my @highlights = (
	[$type_constant, "\$1"],
	[$type_func, "\$1"],
	[$type_struct, "\$1"],
	[$type_param, "\$1"]
);

my $dohighlight = "";
my $prefix = '';

<<<<<<< HEAD
my (%parametertypes, $declaration_purpose);
=======
my $recursive = 0;
my $verbose = 0;
my $output_mode = "list";
my $output_preformatted = 0;
my $no_doc_sections = 0;
my @highlights = @highlights_list;
my $blankline = $blankline_list;
my $modulename = "Kernel API";
my $function_only = 0;
my $show_not_found = 0;

my @build_time;
if (defined($ENV{'KBUILD_BUILD_TIMESTAMP'}) &&
    (my $seconds = `date -d"${ENV{'KBUILD_BUILD_TIMESTAMP'}}" +%s`) ne '') {
    @build_time = gmtime($seconds);
} else {
    @build_time = localtime;
}

my $man_date = ('January', 'February', 'March', 'April', 'May', 'June',
		'July', 'August', 'September', 'October',
		'November', 'December')[$build_time[4]] .
  " " . ($build_time[5]+1900);

# Essentially these are globals.
# They probably want to be tidied up, made more localised or something.
# CAVEAT EMPTOR!  Some of the others I localised may not want to be, which
# could cause "use of undefined value" or other bugs.
my ($function, %function_table, %parametertypes, $declaration_purpose);
>>>>>>> master
my ($type, $declaration_name, $return_type);
my ($prototype, $brcount);

# Generated docbook code is inserted in a template at a point where
# docbook v3.1 requires a non-zero sequence of RefEntry's; see:
# http://www.oasis-open.org/docbook/documentation/reference/html/refentry.html
# We keep track of number of generated entries and generate a dummy
# if needs be to ensure the expanded template can be postprocessed
# into html.
my $section_counter = 0;

# states
# 0 - normal code
# 1 - looking for function name
# 2 - scanning field start.
# 3 - scanning prototype.
# 4 - gathering documentation outside main block
my $state;
my $in_doc_sect;

# Split Doc State
# 0 - Invalid (Before start or after finish)
# 1 - Is started (the /** was found inside a struct)
# 2 - The @parameter header was found, start accepting multi paragraph text.
# 3 - Finished (the */ was found)
# 4 - Error - Comment without header was found. Spit a warning as it's not
#     proper kernel-doc and ignore the rest.
my $split_doc_state;

#declaration types: can be
# 'function', 'struct', 'union', 'enum', 'typedef'
my $decl_type;

my $doc_special = "\@\%\$\&";

my $doc_start = '^/\*\*\s*$'; # Allow whitespace at end of comment start.
my $doc_end = '\*/';
my $doc_com = '\s*\*\s*';
my $doc_com_body = '\s*\* ?';
my $doc_decl = $doc_com . '(\w+)';
my $doc_sect = $doc_com . '([' . $doc_special . ']?[\w\s]+):(.*)';
my $doc_content = $doc_com_body . '(.*)';
my $doc_split_start = '^\s*/\*\*\s*$';
my $doc_split_sect = '\s*\*\s*(@[\w\s]+):(.*)';
my $doc_split_end = '^\s*\*/\s*$';

my %constants;
my %parameterdescs;
my @parameterlist;
my %sections;
my @sectionlist;
my $sectcheck;
my $struct_actual;

my $contents = "";
my $section_default = "Description";	# default section
my $section_intro = "Introduction";
my $section = $section_default;
my $section_context = "Context";
my $section_return = "Return";

my $undescribed = "-- undescribed --";

reset_state();

<<<<<<< HEAD
#Regular expressions
our $Storage = qr{extern|static|asmlinkage};
our $Inline = qr{inline|__always_inline|noinline|__inline|__inline__};
our $InitAttributePrefix = qr{__(?:mem|cpu|dev|net_|)};
our $InitAttributeData = qr{$InitAttributePrefix(?:initdata\b)};
our $InitAttributeConst = qr{$InitAttributePrefix(?:initconst\b)};
our $InitAttributeInit = qr{$InitAttributePrefix(?:init\b)};
our $InitAttribute = qr{$InitAttributeData|$InitAttributeConst|$InitAttributeInit};
our $Attribute = qr{
	const|
	__percpu|
	__nocast|
	__safe|
	__bitwise__|
	__packed__|
	__packed2__|
	__naked|
	__maybe_unused|
	__always_unused|
	__noreturn|
	__used|
	__cold|
	__pure|
	__noclone|
	__deprecated|
	__read_mostly|
	__kprobes|
	$InitAttribute|
	____cacheline_aligned|
	____cacheline_aligned_in_smp|
	____cacheline_internodealigned_in_smp|
	__weak
}x;
our $Sparse = qr{
	__user|
	__kernel|
	__force|
	__iomem|
	__pmem|
	__must_check|
	__init_refok|
	__kprobes|
	__ref|
	__rcu|
	__private
}x;
our @modifierList = (
	qr{fastcall},
);
our @modifierListFile = ();
my $mods = "(?x:  \n" . join("|\n  ", (@modifierList, @modifierListFile)) . "\n)";
our $Ident = qr{
	[A-Za-z_][A-Za-z\d_]*
	(?:\s*\#\#\s*[A-Za-z_][A-Za-z\d_]*)*
}x;
our @typeListMisordered = (
	qr{char\s+(?:un)?signed},
	qr{int\s+(?:(?:un)?signed\s+)?short\s},
	qr{int\s+short(?:\s+(?:un)?signed)},
	qr{short\s+int(?:\s+(?:un)?signed)},
	qr{(?:un)?signed\s+int\s+short},
	qr{short\s+(?:un)?signed},
	qr{long\s+int\s+(?:un)?signed},
	qr{int\s+long\s+(?:un)?signed},
	qr{long\s+(?:un)?signed\s+int},
	qr{int\s+(?:un)?signed\s+long},
	qr{int\s+(?:un)?signed},
	qr{int\s+long\s+long\s+(?:un)?signed},
	qr{long\s+long\s+int\s+(?:un)?signed},
	qr{long\s+long\s+(?:un)?signed\s+int},
	qr{long\s+long\s+(?:un)?signed},
	qr{long\s+(?:un)?signed},
);
our @typeList = (
	qr{void},
	qr{(?:(?:un)?signed\s+)?char},
	qr{(?:(?:un)?signed\s+)?short\s+int},
	qr{(?:(?:un)?signed\s+)?short},
	qr{(?:(?:un)?signed\s+)?int},
	qr{(?:(?:un)?signed\s+)?long\s+int},
	qr{(?:(?:un)?signed\s+)?long\s+long\s+int},
	qr{(?:(?:un)?signed\s+)?long\s+long},
	qr{(?:(?:un)?signed\s+)?long},
	qr{(?:un)?signed},
	qr{float},
	qr{double},
	qr{bool},
	qr{struct\s+$Ident},
	qr{union\s+$Ident},
	qr{enum\s+$Ident},
	qr{${Ident}_t},
	qr{${Ident}_handler},
	qr{${Ident}_handler_fn},
	@typeListMisordered,
);
our @typeListFile = ();
my $all = "(?x:  \n" . join("|\n  ", (@typeList, @typeListFile)) . "\n)";
our $Modifier = qr{(?:$Attribute|$Sparse|$mods)};
our $typeC99Typedefs = qr{(?:__)?(?:[us]_?)?int_?(?:8|16|32|64)_t};
our $typeOtherOSTypedefs = qr{(?x:
	u_(?:char|short|int|long) |          # bsd
	u(?:nchar|short|int|long)            # sysv
)};
our $typeKernelTypedefs = qr{(?x:
	(?:__)?(?:u|s|be|le)(?:8|16|32|64)|
	atomic_t
)};
our $typeTypedefs = qr{(?x:
	$typeC99Typedefs\b|
	$typeOtherOSTypedefs\b|
	$typeKernelTypedefs\b
)};
our $NonptrType = qr{
	(?:$Modifier\s+|const\s+)*
	(?:
		(?:typeof|__typeof__)\s*\([^\)]*\)|
		(?:$typeTypedefs\b)|
		(?:${all}\b)
	)
	(?:\s+$Modifier|\s+const)*
}x;
our $Type = qr{
	$NonptrType
	(?:(?:\s|\*|\[\])+\s*const|(?:\s|\*\s*(?:const\s*)?|\[\])+|(?:\s*\[\s*\])+)?
	(?:\s+$Inline|\s+$Modifier)*
}x;

# generate a sequence of code that will splice in highlighting information
# using the s// operator.
for (my $k = 0; $k < @highlights; $k++) {
	my $pattern = $highlights[$k][0];
	my $result = $highlights[$k][1];

	$dohighlight .=  "\$contents =~ s:$pattern:$result:gs;\n";
=======
# while ($ARGV[0] =~ m/^-(.*)/) {
for my $cmd (@ARGV) {
    if ($cmd =~ m/^-(.*)/) {
	shift @ARGV;
    }
    if ($cmd eq "--version") {
	printVersion();
    } elsif ($cmd eq "-html") {
	$output_mode = "html";
	@highlights = @highlights_html;
	$blankline = $blankline_html;
    } elsif ($cmd eq "-html5") {
	$output_mode = "html5";
	@highlights = @highlights_html5;
	$blankline = $blankline_html5;
    } elsif ($cmd eq "-man") {
	$output_mode = "man";
	@highlights = @highlights_man;
	$blankline = $blankline_man;
    } elsif ($cmd eq "-text") {
	$output_mode = "text";
	@highlights = @highlights_text;
	$blankline = $blankline_text;
    } elsif ($cmd eq "-rst") {
	$output_mode = "rst";
	@highlights = @highlights_rst;
	$blankline = $blankline_rst;
    } elsif ($cmd eq "-docbook") {
	$output_mode = "xml";
	@highlights = @highlights_xml;
	$blankline = $blankline_xml;
    } elsif ($cmd eq "-list") {
	$output_mode = "list";
	@highlights = @highlights_list;
	$blankline = $blankline_list;
    } elsif ($cmd eq "-gnome") {
	$output_mode = "gnome";
	@highlights = @highlights_gnome;
	$blankline = $blankline_gnome;
    } elsif ($cmd eq "-module") { # not needed for XML, inherits from calling document
	$modulename = shift @ARGV;
    } elsif ($cmd eq "-function") { # to only output specific functions
	$function_only = 1;
	$function = shift @ARGV;
	$function_table{$function} = 1;
    } elsif ($cmd eq "-nofunction") { # to only output specific functions
	$function_only = 2;
	$function = shift @ARGV;
	$function_table{$function} = 1;
    } elsif ($cmd eq "-v") {
	$verbose = 1;
    } elsif (($cmd eq "-h") || ($cmd eq "--help")) {
	usage();
    } elsif (($cmd eq "-r") || ($cmd eq "--recursive")) {
	$recursive = 1;
    } elsif ($cmd eq '-no-doc-sections') {
	$no_doc_sections = 1;
    } elsif ($cmd eq '-show-not-found') {
	$show_not_found = 1;
    }
>>>>>>> master
}

my $exit = 0;

my $total_warns = 0;
my $total_lines = 0;
my $total_files = 0;

foreach my $filename (@ARGV) {
	if (! -f $filename) {
		print STDERR "$filename: No such file\n";
		next;
	}
	if ($filename !~ /\.(h|c)$/) {
		print STDERR "$filename: Not a C source file\n";
		next;
	}
	$total_files++;
	if (!process($filename)) {
		$exit = 1;
	}
}

if ($exit != 0 && !$brief) {
	my $warns_plural = "";
	$warns_plural = "s" if ($total_warns > 1);
	my $line_plural = "";
	$line_plural = "s" if ($total_lines > 1);
	my $file_plural = "";
	$file_plural = "s" if ($total_files > 1);

	print "Total: ";
	print "$total_warns warning$warns_plural, ";
	print "$total_lines line$line_plural checked in $total_files file$file_plural\n";
}

exit($exit);

##
# dumps section contents to arrays/hashes intended for that purpose.
#
sub dump_section {
	my $file = shift;
	my $name = shift;
	my $contents = join "\n", @_;

	if ($name =~ m/$type_constant/) {
		$name = $1;
		$constants{$name} = $contents;
	} elsif ($name =~ m/$type_param/) {
		$name = $1;
		$parameterdescs{$name} = $contents;
		$sectcheck = $sectcheck . $name . " ";
	} elsif ($name eq "@\.\.\.") {
		$name = "...";
		$parameterdescs{$name} = $contents;
		$sectcheck = $sectcheck . $name . " ";
	} else {
		if (defined($sections{$name}) && ($sections{$name} ne "")) {
			WARN("duplicate section name '$name'");
			# print STDERR "${file}:$.: error: duplicate section name '$name'\n";
			# ++$errors;
		}
		$sections{$name} = $contents;
		push @sectionlist, $name;
	}
}

## list mode output functions

sub output_function_list(%) {
	my %args = %{$_[0]};
	print STDOUT $args{'function'} . "\n";
}

# output enum in list
sub output_enum_list(%) {
	my %args = %{$_[0]};
	print STDOUT "enum " . $args{'enum'} . "\n";
}

# output typedef in list
sub output_typedef_list(%) {
	my %args = %{$_[0]};
	print STDOUT $args{'typedef'} . "\n";
}

# output struct as list
sub output_struct_list(%) {
	my %args = %{$_[0]};
	print STDOUT "struct " . $args{'struct'} . "\n";
}

##
# generic output function for all types (function, struct/union, typedef, enum);
# calls the generated, variable output_ function name based on
# functype and output_mode
sub output_declaration {
	no strict 'refs';
	my $name = shift;
	my $functype = shift;
	my $func = "output_${functype}_list";

	# TODO: Optional output
	# &$func(@_);
	$section_counter++;
}

##
# takes a declaration (struct, union, enum, typedef) and
# invokes the right handler. NOT called for functions.
sub dump_declaration($$) {
	no strict 'refs';
	my ($prototype, $file) = @_;
	my $func = "dump_" . $decl_type;
	&$func(@_);
}

sub dump_union($$) {
	dump_struct(@_);
}

sub dump_struct($$) {
	my $x = shift;
	my $file = shift;
	my $nested;

	if ($x =~ /(struct|union)\s+(\w+)\s*{(.*)}/) {
		#my $decl_type = $1;
		$declaration_name = $2;
		my $members = $3;

<<<<<<< HEAD
		# ignore embedded structs or unions
		$members =~ s/({.*})//g;
		$nested = $1;
=======
	# ignore embedded structs or unions
	$members =~ s/(\{.*})//g;
	$nested = $1;
>>>>>>> master

		# ignore members marked private:
		$members =~ s/\/\*\s*private:.*?\/\*\s*public:.*?\*\///gosi;
		$members =~ s/\/\*\s*private:.*//gosi;
		# strip comments:
		$members =~ s/\/\*.*?\*\///gos;
		$nested =~ s/\/\*.*?\*\///gos;
		# strip kmemcheck_bitfield_{begin,end}.*;
		$members =~ s/kmemcheck_bitfield_.*?;//gos;
		# strip attributes
		$members =~ s/__attribute__\s*\(\([a-z,_\*\s\(\)]*\)\)//i;
		$members =~ s/__aligned\s*\([^;]*\)//gos;
		$members =~ s/\s*CRYPTO_MINALIGN_ATTR//gos;
		# replace DECLARE_BITMAP
		$members =~ s/DECLARE_BITMAP\s*\(([^,)]+), ([^,)]+)\)/unsigned long $1\[BITS_TO_LONGS($2)\]/gos;

		create_parameterlist($members, ';', $file);
		check_sections($file, $declaration_name, "struct", $sectcheck, $struct_actual, $nested);

		output_declaration($declaration_name,
		    'struct',
		    {'struct' => $declaration_name,
		     'parameterlist' => \@parameterlist,
		     'parameterdescs' => \%parameterdescs,
		     'parametertypes' => \%parametertypes,
		     'sectionlist' => \@sectionlist,
		     'sections' => \%sections,
		     'purpose' => $declaration_purpose,
		     'type' => $decl_type
		    }
		);
	}
	else {
		WARN("Cannot parse struct or union!");
		# print STDERR "${file}:$.: error: Cannot parse struct or union!\n";
		# ++$errors;
	}
}

sub dump_enum($$) {
	my $x = shift;
	my $file = shift;

	$x =~ s@/\*.*?\*/@@gos;	# strip comments.
	# strip #define macros inside enums
	$x =~ s@#\s*((define|ifdef)\s+|endif)[^;]*;@@gos;

	if ($x =~ /enum\s+(\w+)\s*{(.*)}/) {
		$declaration_name = $1;
		my $members = $2;

		foreach my $arg (split ',', $members) {
			$arg =~ s/^\s*(\w+).*/$1/;
			push @parameterlist, $arg;
			if (!$parameterdescs{$arg}) {
				$parameterdescs{$arg} = $undescribed;
				WARN("Enum value '$arg' ".
				    "not described in enum '$declaration_name'");
				# print STDERR "${file}:$.: warning: Enum value '$arg' ".
				#     "not described in enum '$declaration_name'\n";
				# ++$warnings;
			}
		}

		output_declaration($declaration_name,
		    'enum',
		    {'enum' => $declaration_name,
		     'parameterlist' => \@parameterlist,
		     'parameterdescs' => \%parameterdescs,
		     'sectionlist' => \@sectionlist,
		     'sections' => \%sections,
		     'purpose' => $declaration_purpose
		    }
		);
	}
	else {
		WARN("Cannot parse enum!");
		# print STDERR "${file}:$.: error: Cannot parse enum!\n";
		# ++$errors;
	}
}

sub dump_typedef($$) {
	my $x = shift;
	my $file = shift;

	$x =~ s@/\*.*?\*/@@gos;	# strip comments.

	# Parse function prototypes
	if ($x =~ /typedef\s+(\w+)\s*\(\*\s*(\w\S+)\s*\)\s*\((.*)\);/) {
		# Function typedefs
		$return_type = $1;
		$declaration_name = $2;
		my $args = $3;

		create_parameterlist($args, ',', $file);

		output_declaration($declaration_name,
		    'function',
		    {'function' => $declaration_name,
		     'functiontype' => $return_type,
		     'parameterlist' => \@parameterlist,
		     'parameterdescs' => \%parameterdescs,
		     'parametertypes' => \%parametertypes,
		     'sectionlist' => \@sectionlist,
		     'sections' => \%sections,
		     'purpose' => $declaration_purpose
		    }
		);
		return;
	}

	while (($x =~ /\(*.\)\s*;$/) || ($x =~ /\[*.\]\s*;$/)) {
		$x =~ s/\(*.\)\s*;$/;/;
		$x =~ s/\[*.\]\s*;$/;/;
	}

	if ($x =~ /typedef.*\s+(\w+)\s*;/) {
		$declaration_name = $1;

		output_declaration($declaration_name,
		    'typedef',
		    {'typedef' => $declaration_name,
		     'sectionlist' => \@sectionlist,
		     'sections' => \%sections,
		     'purpose' => $declaration_purpose
		    }
		);
	}
	else {
		WARN("Cannot parse typedef!");
		# print STDERR "${file}:$.: error: Cannot parse typedef!\n";
		# ++$errors;
	}
}

sub save_struct_actual($) {
	my $actual = shift;

	# strip all spaces from the actual param so that it looks like one string item
	$actual =~ s/\s*//g;
	$struct_actual = $struct_actual . $actual . " ";
}

sub create_parameterlist($$$) {
	my $args = shift;
	my $splitter = shift;
	my $file = shift;
	my $type;
	my $param;

	# temporarily replace commas inside function pointer definition
	while ($args =~ /(\([^\),]+),/) {
		$args =~ s/(\([^\),]+),/$1#/g;
	}

	foreach my $arg (split($splitter, $args)) {
		# strip comments
		$arg =~ s/\/\*.*\*\///;
		# strip leading/trailing spaces
		$arg =~ s/^\s*//;
		$arg =~ s/\s*$//;
		$arg =~ s/\s+/ /;

		if ($arg =~ /^#/) {
			# Treat preprocessor directive as a typeless variable just to fill
			# corresponding data structures "correctly". Catch it later in
			# output_* subs.
			push_parameter($arg, "", $file);
		} elsif ($arg =~ m/\(.+\)\s*\(/) {
			# pointer-to-function
			$arg =~ tr/#/,/;
			$arg =~ m/[^\(]+\(\*?\s*(\w*)\s*\)/;
			$param = $1;
			$type = $arg;
			$type =~ s/([^\(]+\(\*?)\s*$param/$1/;
			save_struct_actual($param);
			push_parameter($param, $type, $file);
		} elsif ($arg) {
			$arg =~ s/\s*:\s*/:/g;
			$arg =~ s/\s*\[/\[/g;

			my @args = split('\s*,\s*', $arg);
			if ($args[0] =~ m/\*/) {
				$args[0] =~ s/(\*+)\s*/ $1/;
			}

			my @first_arg;
			if ($args[0] =~ /^(.*\s+)(.*?\[.*\].*)$/) {
				shift @args;
				push(@first_arg, split('\s+', $1));
				push(@first_arg, $2);
			} else {
				@first_arg = split('\s+', shift @args);
			}

			unshift(@args, pop @first_arg);
			$type = join " ", @first_arg;

			foreach $param (@args) {
				if ($param =~ m/^(\*+)\s*(.*)/) {
					save_struct_actual($2);
					push_parameter($2, "$type $1", $file);
				}
				elsif ($param =~ m/(.*?):(\d+)/) {
					if ($type ne "") { # skip unnamed bit-fields
						save_struct_actual($1);
						push_parameter($1, "$type:$2", $file)
					}
				}
				else {
					save_struct_actual($param);
					push_parameter($param, $type, $file);
				}
			}
		}
	}
}

sub push_parameter($$$) {
	my $param = shift;
	my $type = shift;
	my $file = shift;

	if (($anon_struct_union == 1) && ($type eq "") &&
	    ($param eq "}")) {
		return; # ignore the ending }; from anon. struct/union
	}

	$anon_struct_union = 0;
	$param =~ s/\[.*//;
	$param =~ s/\)//;
	my $param_name = $param;


	if ($type eq "" && $param =~ /\.\.\.$/) {
		if (!defined $parameterdescs{$param} || $parameterdescs{$param} eq "") {
			$parameterdescs{$param} = "variable arguments";
		}
	}
	elsif ($type eq "" && ($param eq "" or $param eq "void")) {
		$param="void";
		$parameterdescs{void} = "no arguments";
	}
	elsif ($type eq "" && ($param eq "struct" or $param eq "union"))
	# handle unnamed (anonymous) union or struct:
	{
		$type = $param;
		$param = "{unnamed_" . $param . "}";
		$parameterdescs{$param} = "anonymous\n";
		$anon_struct_union = 1;
	}

	# warn if parameter has no description
	# (but ignore ones starting with # as these are not parameters
	# but inline preprocessor statements);
	# also ignore unnamed structs/unions;
	if (!$anon_struct_union) {
		if (!defined $parameterdescs{$param_name} && $param_name !~ /^#/) {

			$parameterdescs{$param_name} = $undescribed;

			if (($type eq 'function') || ($type eq 'enum')) {
				WARN("Function parameter ".
				    "or member '$param' not " .
				    "described in '$declaration_name'");
				# print STDERR "${file}:$.: warning: Function parameter ".
				#     "or member '$param' not " .
				#     "described in '$declaration_name'\n";
			}
			my $tmpLine = $. - 1;
			my $oldPrefix = $prefix;
			$prefix = "$file:$tmpLine: ";
			WARN("No description found for parameter or member '$param'");
			$prefix = $oldPrefix;
			# print STDERR "${file}:$tmpLine: warning:" .
			#     " No description found for parameter or member '$param'\n";
			# ++$warnings;
		}
	}

	$param = xml_escape($param);

	# strip spaces from $param so that it is one continuous string
	# on @parameterlist;
	# this fixes a problem where check_sections() cannot find
	# a parameter like "addr[6 + 2]" because it actually appears
	# as "addr[6", "+", "2]" on the parameter list;
	# but it's better to maintain the param string unchanged for output,
	# so just weaken the string compare in check_sections() to ignore
	# "[blah" in a parameter string;
	###$param =~ s/\s*//g;
	push @parameterlist, $param;
	$parametertypes{$param} = $type;
}

sub check_sections($$$$$$) {
	my ($file, $decl_name, $decl_type, $sectcheck, $prmscheck, $nested) = @_;
	my @sects = split ' ', $sectcheck;
	my @prms = split ' ', $prmscheck;
	my $err;
	my ($px, $sx);
	my $prm_clean;		# strip trailing "[array size]" and/or beginning "*"

	foreach $sx (0 .. $#sects) {
		$err = 1;
		foreach $px (0 .. $#prms) {
			$prm_clean = $prms[$px];
			$prm_clean =~ s/\[.*\]//;
			$prm_clean =~ s/__attribute__\s*\(\([a-z,_\*\s\(\)]*\)\)//i;
			# ignore array size in a parameter string;
			# however, the original param string may contain
			# spaces, e.g.:  addr[6 + 2]
			# and this appears in @prms as "addr[6" since the
			# parameter list is split at spaces;
			# hence just ignore "[..." for the sections check;
			$prm_clean =~ s/\[.*//;

			##$prm_clean =~ s/^\**//;
			if ($prm_clean eq $sects[$sx]) {
				$err = 0;
				last;
			}
		}
		if ($err) {
			if ($decl_type eq "function") {
				WARN("Excess function parameter " .
				"'$sects[$sx]' " .
				"description in '$decl_name'");
				# print STDERR "${file}:$.: warning: " .
					# "Excess function parameter " .
					# "'$sects[$sx]' " .
					# "description in '$decl_name'\n";
				# ++$warnings;
			} else {
				if ($nested !~ m/\Q$sects[$sx]\E/) {
					WARN("Excess struct/union/enum/typedef member " .
					"'$sects[$sx]' " .
					"description in '$decl_name'");
					# print STDERR "${file}:$.: warning: " .
					#     "Excess struct/union/enum/typedef member " .
					#     "'$sects[$sx]' " .
					#     "description in '$decl_name'\n";
					# ++$warnings;
				}
			}
		}
	}
}

##
# Checks the section describing the return value of a function.
sub check_return_section {
	my $file = shift;
	my $declaration_name = shift;
	my $return_type = shift;
	my $real_line = $. - 1;

	# Ignore an empty return type (It's a macro)
	# Ignore functions with a "void" return type. (But don't ignore "void *")
	if (($return_type eq "") || ($return_type =~ /void\s*\w*\s*$/)) {
		return;
	}

	if (!defined($sections{$section_return}) ||
	    $sections{$section_return} eq "") {
		my $oldPrefix = $prefix;
		$prefix = "$file:$real_line: ";
		WARN("No description found for return value of " .
		"'$declaration_name'");
		$prefix = $oldPrefix;
		# print STDERR "${file}:$real_line: warning: " .
		#     "No description found for return value of " .
		#     "'$declaration_name'\n";
		# ++$warnings;
	}
}

##
# takes a function prototype and the name of the current file being
# processed and spits out all the details stored in the global
# arrays/hashes.
sub dump_function($$) {
	my $prototype = shift;
	my $file = shift;
	my $noret = 0;

	$prototype =~ s/^static +//;
	$prototype =~ s/^extern +//;
	$prototype =~ s/^asmlinkage +//;
	$prototype =~ s/^inline +//;
	$prototype =~ s/^__inline__ +//;
	$prototype =~ s/^__inline +//;
	$prototype =~ s/^__always_inline +//;
	$prototype =~ s/^noinline +//;
	$prototype =~ s/__init +//;
	$prototype =~ s/__init_or_module +//;
	$prototype =~ s/__meminit +//;
	$prototype =~ s/__must_check +//;
	$prototype =~ s/__weak +//;
	my $define = $prototype =~ s/^#\s*define\s+//; #ak added
	$prototype =~ s/__attribute__\s*\(\([a-z,]*\)\)//;

	# Yes, this truly is vile.  We are looking for:
	# 1. Return type (may be nothing if we're looking at a macro)
	# 2. Function name
	# 3. Function parameters.
	#
	# All the while we have to watch out for function pointer parameters
	# (which IIRC is what the two sections are for), C types (these
	# regexps don't even start to express all the possibilities), and
	# so on.
	#
	# If you mess with these regexps, it's a good idea to check that
	# the following functions' documentation still comes out right:
	# - parport_register_device (function pointer parameters)
	# - atomic_set (macro)
	# - pci_match_device, __copy_to_user (long return type)

<<<<<<< HEAD
	if ($define && $prototype =~ m/^()([a-zA-Z0-9_~:]+)\s+/) {
		# This is an object-like macro, it has no return type and no parameter
		# list.
		# Function-like macros are not allowed to have spaces between
		# declaration_name and opening parenthesis (notice the \s+).
		$return_type = $1;
		$declaration_name = $2;
		$noret = 1;
	}
	# TODO: Use Better Regex ...
	elsif ($prototype =~ m/^()([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	    $prototype =~ m/^(\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	    $prototype =~ m/^(\w+\s*\*)\s*(?:\**\s*)?([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s*\*+)\s*([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s+\w+\s*\*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	    $prototype =~ m/^()([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+\s*\*+)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s*\*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s+\w+\s*\*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s+\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s+\w+\s+\w+\s*\*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	    $prototype =~ m/^(\w+\s+\w+\s*\*\s*\w+\s*\*\s*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/)  {
		$return_type = $1;
		$declaration_name = $2;
		my $args = $3;

		create_parameterlist($args, ',', $file);
	} else {
		if ($prototype !~ /^(?:typedef\s*)?(struct|enum|union)/) {
			WARN("cannot understand function prototype: '$prototype'");
			# print STDERR "${file}:$.: error: cannot understand function prototype: '$prototype'\n";
			# ++$errors;
		}
		return;
=======
    if ($define && $prototype =~ m/^()([a-zA-Z0-9_~:]+)\s+/) {
        # This is an object-like macro, it has no return type and no parameter
        # list.
        # Function-like macros are not allowed to have spaces between
        # declaration_name and opening parenthesis (notice the \s+).
        $return_type = $1;
        $declaration_name = $2;
        $noret = 1;
    } elsif (($prototype =~ m/^()([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	$prototype =~ m/^(\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	$prototype =~ m/^(\w+\s*\*)\s*(?:\**\s*)?([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s*\*+)\s*([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s+\w+\s*\*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\(]*)\)/ ||
	$prototype =~ m/^()([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+\s*\*+)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s*\*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s+\w+\s*\*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s+\w+\s+\w+)\s+([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s+\w+\s+\w+\s*\*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/ ||
	$prototype =~ m/^(\w+\s+\w+\s*\*\s*\w+\s*\*\s*)\s*([a-zA-Z0-9_~:]+)\s*\(([^\{]*)\)/) &&
	$prototype !~ m/^typedef/)  {
	$return_type = $1;
	$declaration_name = $2;
	my $args = $3;

	create_parameterlist($args, ',', $file);
    } else {
	if ($prototype !~ /^(?:typedef\s*)?(struct|enum|union)/ &&
	    $prototype !~ /^typedef/) {
		print STDERR "${file}:$.: error: cannot understand function prototype: '$prototype'\n";
		++$errors;
>>>>>>> master
	}

	my $prms = join " ", @parameterlist;
	check_sections($file, $declaration_name, "function", $sectcheck, $prms, "");

	if (!$noret) {
		check_return_section($file, $declaration_name, $return_type);
	}

	output_declaration($declaration_name,
	    'function',
	    {'function' => $declaration_name,
	     'functiontype' => $return_type,
	     'parameterlist' => \@parameterlist,
	     'parameterdescs' => \%parameterdescs,
	     'parametertypes' => \%parametertypes,
	     'sectionlist' => \@sectionlist,
	     'sections' => \%sections,
	     'purpose' => $declaration_purpose
	    });
}

sub reset_state {
	%constants = ();
	%parameterdescs = ();
	%parametertypes = ();
	@parameterlist = ();
	%sections = ();
	@sectionlist = ();
	$sectcheck = "";
	$struct_actual = "";
	$prototype = "";

	$state = 0;
	$split_doc_state = 0;
}

sub process_state3_function($$) {
	my $x = shift;
	my $file = shift;

	$x =~ s@\/\/.*$@@gos; # strip C99-style comments to end of line

	if ($x =~ /([^\{]*)/) {
		$prototype .= $1;
	}

	if (($x =~ /\{/) || ($x =~ /\#\s*define/) || ($x =~ /;/)) {
		$prototype =~ s@/\*.*?\*/@@gos;	# strip comments.
		$prototype =~ s@[\r\n]+@ @gos; # strip newlines/cr's.
		$prototype =~ s@^\s+@@gos; # strip leading spaces
		dump_function($prototype, $file);
		reset_state();
	}
}

sub process_state3_type($$) {
	my $x = shift;
	my $file = shift;

	$x =~ s@[\r\n]+@ @gos; # strip newlines/cr's.
	$x =~ s@^\s+@@gos; # strip leading spaces
	$x =~ s@\s+$@@gos; # strip trailing spaces
	$x =~ s@\/\/.*$@@gos; # strip C99-style comments to end of line

	if ($x =~ /^#/) {
		# To distinguish preprocessor directive from regular declaration later.
		$x .= ";";
	}

	while (1) {
		if ( $x =~ /([^{};]*)([{};])(.*)/ ) {
			$prototype .= $1 . $2;
			($2 eq '{') && $brcount++;
			($2 eq '}') && $brcount--;
			if (($2 eq ';') && ($brcount == 0)) {
				dump_declaration($prototype, $file);
				reset_state();
				last;
			}
			$x = $3;
		} else {
			$prototype .= $x;
			last;
		}
	}
}

# xml_escape: replace <, >, and & in the text stream;
sub xml_escape($) {
	my $text = shift;

	$text =~ s/\&/\\\\\\amp;/g;
	$text =~ s/\</\\\\\\lt;/g;
	$text =~ s/\>/\\\\\\gt;/g;
	return $text;
}

sub report {
	my ($msg) = @_;
	$msg = (split('\n', $msg))[0];

	my $output = '';
	my $line = (split(":", $prefix))[1]; # Line number only
	$output .= RED if (-t STDOUT && $color);
	$output .= "line $line:";
	$output .= RESET if (-t STDOUT && $color);
	$output .= ' ' . $msg;

	$output = (split('\n', $output))[0] . "\n";

	push(our @report, $output);

	return 1;
}

sub report_dump {
	our @report;
}

<<<<<<< HEAD
sub WARN {
	my ($msg) = @_;
=======
#Regular expressions
our $Storage	= qr{extern|static|asmlinkage};
our $Inline	= qr{inline|__always_inline|noinline|__inline|__inline__};
our $InitAttributePrefix = qr{__(?:mem|cpu|dev|net_|)};
our $InitAttributeData = qr{$InitAttributePrefix(?:initdata\b)};
our $InitAttributeConst = qr{$InitAttributePrefix(?:initconst\b)};
our $InitAttributeInit = qr{$InitAttributePrefix(?:init\b)};
our $InitAttribute = qr{$InitAttributeData|$InitAttributeConst|$InitAttributeInit};
our $Attribute	= qr{
			const|
			__percpu|
			__nocast|
			__safe|
			__bitwise__|
			__packed__|
			__packed2__|
			__naked|
			__maybe_unused|
			__always_unused|
			__noreturn|
			__used|
			__cold|
			__pure|
			__noclone|
			__deprecated|
			__read_mostly|
			__kprobes|
			$InitAttribute|
			____cacheline_aligned|
			____cacheline_aligned_in_smp|
			____cacheline_internodealigned_in_smp|
			__weak
		  }x;
our $Sparse	= qr{
			__user|
			__kernel|
			__force|
			__iomem|
			__pmem|
			__must_check|
			__init_refok|
			__kprobes|
			__ref|
			__rcu|
			__private
		}x;
our @modifierList = (
	qr{fastcall},
);
our @modifierListFile = ();
my $mods = "(?x:  \n" . join("|\n  ", (@modifierList, @modifierListFile)) . "\n)";
our $Ident	= qr{
			[A-Za-z_][A-Za-z\d_]*
			(?:\s*\#\#\s*[A-Za-z_][A-Za-z\d_]*)*
		}x;
our @typeListMisordered = (
	qr{char\s+(?:un)?signed},
	qr{int\s+(?:(?:un)?signed\s+)?short\s},
	qr{int\s+short(?:\s+(?:un)?signed)},
	qr{short\s+int(?:\s+(?:un)?signed)},
	qr{(?:un)?signed\s+int\s+short},
	qr{short\s+(?:un)?signed},
	qr{long\s+int\s+(?:un)?signed},
	qr{int\s+long\s+(?:un)?signed},
	qr{long\s+(?:un)?signed\s+int},
	qr{int\s+(?:un)?signed\s+long},
	qr{int\s+(?:un)?signed},
	qr{int\s+long\s+long\s+(?:un)?signed},
	qr{long\s+long\s+int\s+(?:un)?signed},
	qr{long\s+long\s+(?:un)?signed\s+int},
	qr{long\s+long\s+(?:un)?signed},
	qr{long\s+(?:un)?signed},
);
our @typeList = (
	qr{void},
	qr{(?:(?:un)?signed\s+)?char},
	qr{(?:(?:un)?signed\s+)?short\s+int},
	qr{(?:(?:un)?signed\s+)?short},
	qr{(?:(?:un)?signed\s+)?int},
	qr{(?:(?:un)?signed\s+)?long\s+int},
	qr{(?:(?:un)?signed\s+)?long\s+long\s+int},
	qr{(?:(?:un)?signed\s+)?long\s+long},
	qr{(?:(?:un)?signed\s+)?long},
	qr{(?:un)?signed},
	qr{float},
	qr{double},
	qr{bool},
	qr{struct\s+$Ident},
	qr{union\s+$Ident},
	qr{enum\s+$Ident},
	qr{${Ident}_t},
	qr{${Ident}_handler},
	qr{${Ident}_handler_fn},
	@typeListMisordered,
);
our @typeListFile = ();
my $all = "(?x:  \n" . join("|\n  ", (@typeList, @typeListFile)) . "\n)";
our $Modifier	= qr{(?:$Attribute|$Sparse|$mods)};
our $typeC99Typedefs = qr{(?:__)?(?:[us]_?)?int_?(?:8|16|32|64)_t};
our $typeOtherOSTypedefs = qr{(?x:
	u_(?:char|short|int|long) |          # bsd
	u(?:nchar|short|int|long)            # sysv
)};
our $typeKernelTypedefs = qr{(?x:
	(?:__)?(?:u|s|be|le)(?:8|16|32|64)|
	atomic_t
)};
our $typeTypedefs = qr{(?x:
	$typeC99Typedefs\b|
	$typeOtherOSTypedefs\b|
	$typeKernelTypedefs\b
)};
our $NonptrType	= qr{
		(?:$Modifier\s+|const\s+)*
		(?:
			(?:typeof|__typeof__)\s*\([^\)]*\)|
			(?:$typeTypedefs\b)|
			(?:${all}\b)
		)
		(?:\s+$Modifier|\s+const)*
	  }x;
our $Type	= qr{
		$NonptrType\b
		(?:(?:\s|\*|\[\])+\s*const\b|(?:\s|\*\s*(?:const\b\s*)?|\[\])+|(?:\s*\[\s*\])+)?
		(?:\s+$Inline|\s+$Modifier)*
	  }x;
>>>>>>> master

	if (report($msg)) {
		our $clean = 0;
		our $warnings++;
		$total_warns++;
		return 1;
	}
	return 0;
}

sub process {
	my $filename = shift;
	my $identifier;
	my $func;
	my $descr;
	my $in_purpose = 0;
	my $initial_section_counter = $section_counter;

	our $clean = 1;
	our @report = ();
	our $errors = 0;
	our $warnings = 0;
	our $cnt_lines = 0;
	$prefix = '';

	my $FILE;
	if (!open($FILE,'<', $filename)) {
		print STDERR "$P: Couldn't open file $filename\n";
		return (1);
	}

	$. = 1;
	$section_counter = 0;
	while (<$FILE>) {
		$total_lines++;
		while (s/\\\s*$//) {
			$_ .= <$FILE>;
			$total_lines++;
		}
		$prefix = "$filename:$.: ";

<<<<<<< HEAD
		# print "($.)STATE:$state($in_doc_sect)\t$_\n";
		$cnt_lines++;

		my $attr = qr{__attribute__\s*\(\(\w+\)\)};
=======
	if ($_ =~ /^(?:typedef\s+)?(?:(?:$Storage|$Inline)\s*)*\s*$Type\s*(?:$attr\s*)?\(?\**($Ident)\s*\(.*\)/s &&
	    $_ !~ /;\s*$/)
	{
		# print STDOUT "Function found: $1\n";
		if (!length $identifier || $identifier ne $1) {
			print STDERR "${file}:$.: warning: no description found for function $1\n";
			++$warnings;
		}
		elsif ($_ =~ /^(?:(?:$Storage|$Inline)\s*)*\s*($Type)\s*\(\**($Ident)\s*\((.*)\)\)\s*\(/s) {
			my $type_ = $1;
			my $func_ = $2;
			my $params_ = $3;
			$_ = "${type_} *${func_} (${params_})\n";
			# print "LINE:$_\n";
			# print "FUNCTION -> ${type_} ${func_} (${params_})\n";
		}
		elsif ($_ =~ $attr) {
			$_ =~ s/__attribute__\s*\(\(\w+\)\)//;
			# print "LINE:$_\n";
		}
	}

	if ($_ =~ /^\s*(?:typedef\s+)?(enum|union|struct)(?:\s+($Ident))?\s*.*/s &&
	    $_ !~ /;\s*$/ &&
		$_ !~ /\(.*\)\s*$/)
	{
		# print STDOUT "$1 found: $2\n";
		if (!length $identifier ||
		    !defined $2 ||
		    (defined $1 && defined $2 &&$identifier ne "$1 $2")) {
			print STDERR "${file}:$.: warning: no description found for $1";
			print STDERR " $2" if (defined $2);
			print STDERR "\n";
			++$warnings;
		}
	}
>>>>>>> master

		if ($_ =~ /^(?:typedef\s+)?(?:(?:$Storage|$Inline)\s*)*\s*$Type\s*(?:$attr\s*)?\(?\**($Ident)\s*\(.*\)/s &&
		    $_ !~ /;\s*$/) {
			# print STDOUT "Function found: $1\n";
			if (!length $identifier || $identifier ne $1) {
				WARN("no description found for function $1");
				# print STDERR "${file}:$.: warning: no description found for function $1\n";
				# ++$warnings;
			}
			elsif ($_ =~ /^(?:(?:$Storage|$Inline)\s*)*\s*($Type)\s*\(\**($Ident)\s*\((.*)\)\)\s*\(/s) {
				my $type_ = $1;
				my $func_ = $2;
				my $params_ = $3;
				$_ = "${type_} *${func_} (${params_})\n";
				# print "LINE:$_\n";
				# print "FUNCTION -> ${type_} ${func_} (${params_})\n";
			}
			elsif ($_ =~ $attr) {
				$_ =~ s/__attribute__\s*\(\(\w+\)\)//;
				# print "LINE:$_\n";
			}
		}

		if ($_ =~ /^\s*(?:typedef\s+)?(enum|union|struct)(?:\s+($Ident))?\s*.*/s &&
		    $_ !~ /;\s*$/) {
			# print STDOUT "$1 found: $2\n";
			if (!length $identifier || $identifier ne "$1 $2") {
				WARN("no description found for $1 $2");
				# print STDERR "${file}:$.: warning: no description found for $1 $2\n";
				# ++$warnings;
			}
		}

		if ($state == 0) {
			if (/$doc_start/o) {
				$state = 1; # next line is always the function name
				$in_doc_sect = 0;
			}
		} elsif ($state == 1) { # this line is the function name (always)
			if (/$doc_decl/o) {
				$identifier = $1;
				if (/\s*([\w\s]+?)\s*-/) {
					$identifier = $1;
				}

				$state = 2;
				if (/-(.*)/) {
					# strip leading/trailing/multiple spaces
					$descr= $1;
					$descr =~ s/^\s*//;
					$descr =~ s/\s*$//;
					$descr =~ s/\s+/ /g;
					$declaration_purpose = xml_escape($descr);
					$in_purpose = 1;
				} else {
					$declaration_purpose = "";
				}

				if (($declaration_purpose eq "")) {
					WARN("missing initial short description");
					# print STDERR "${file}:$.: warning: missing initial short description\n";
					#print STDERR $_;
					# ++$warnings;
				}

				if ($identifier =~ m/^struct/) {
					$decl_type = 'struct';
				} elsif ($identifier =~ m/^union/) {
					$decl_type = 'union';
				} elsif ($identifier =~ m/^enum/) {
					$decl_type = 'enum';
				} elsif ($identifier =~ m/^typedef/) {
					$decl_type = 'typedef';
				} else {
					$decl_type = 'function';
				}

				if ($verbose) {
					print STDERR "${filename}:$.: info: Scanning doc for $identifier\n";
				}
			} else {
				WARN("Cannot understand $_ on line $." .
				    " - I thought it was a doc line");
				# print STDERR "${file}:$.: warning: Cannot understand $_ on line $.",
				#     " - I thought it was a doc line\n";
				# ++$warnings;
				$state = 0;
			}
		} elsif ($state == 2) {	# look for head: lines, and include content
			if (/$doc_sect/o) {
				my $newsection = $1;
				my $newcontents = $2;

				if (($contents ne "") && ($contents ne "\n")) {
					if (!$in_doc_sect && $verbose) {
						WARN("contents before sections");
						# print STDERR "${file}:$.: warning: contents before sections\n";
						# ++$warnings;
					}
					dump_section($filename, $section, xml_escape($contents));
					$section = $section_default;
				}

				$in_doc_sect = 1;
				$in_purpose = 0;
				$contents = $newcontents;
				if ($contents ne "") {
					while ((substr($contents, 0, 1) eq " ") ||
					    substr($contents, 0, 1) eq "\t") {
						$contents = substr($contents, 1);
					}
					$contents .= "\n";
				}
				$section = $newsection;
			} elsif (/$doc_end/) {
				if (($contents ne "") && ($contents ne "\n")) {
					dump_section($filename, $section, xml_escape($contents));
					$section = $section_default;
					$contents = "";
				}
				# look for doc_com + <text> + doc_end:
				if ($_ =~ m'\s*\*\s*[a-zA-Z_0-9:\.]+\*/') {
					WARN("suspicious ending line: $_");
					# print STDERR "${file}:$.: warning: suspicious ending line: $_";
					# ++$warnings;
				}

				$prototype = "";
				$state = 3;
				$brcount = 0;
				# print STDERR "end of doc comment, looking for prototype\n";
			} elsif (/$doc_content/) {
				# miguel-style comment kludge, look for blank lines after
				# @parameter line to signify start of description
				if ($1 eq "") {
					if ($section =~ m/^@/ || $section eq $section_context) {
						dump_section($filename, $section, xml_escape($contents));
						$section = $section_default;
						$contents = "";
					} else {
						$contents .= "\n";
					}
					$in_purpose = 0;
				} elsif ($in_purpose == 1) {
					# Continued declaration purpose
					chomp($declaration_purpose);
					$declaration_purpose .= " " . xml_escape($1);
					$declaration_purpose =~ s/\s+/ /g;
				} else {
					$contents .= $1 . "\n";
				}
			} else {
				# i dont know - bad line?  ignore.
				WARN("bad line: $_");
				# print STDERR "${file}:$.: warning: bad line: $_";
				# ++$warnings;
			}
		} elsif ($state == 3) {	# scanning for function '{' (end of prototype)
			if (/$doc_split_start/) {
				$state = 4;
				$split_doc_state = 1;
			} elsif ($decl_type eq 'function' && $_ !~ /(?:struct|enum|union)+/) {
				process_state3_function($_, $filename);
			} else {
				process_state3_type($_, $filename);
			}
		} elsif ($state == 4) { # scanning for split parameters
			# First line (state 1) needs to be a @parameter
			if ($split_doc_state == 1 && /$doc_split_sect/o) {
				$section = $1;
				$contents = $2;
				if ($contents ne "") {
					while ((substr($contents, 0, 1) eq " ") ||
					    substr($contents, 0, 1) eq "\t") {
						$contents = substr($contents, 1);
					}
					$contents .= "\n";
				}
				$split_doc_state = 2;
			# Documentation block end */
			} elsif (/$doc_split_end/) {
				if (($contents ne "") && ($contents ne "\n")) {
					dump_section($filename, $section, xml_escape($contents));
					$section = $section_default;
					$contents = "";
				}
				$state = 3;
				$split_doc_state = 0;
			# Regular text
			} elsif (/$doc_content/) {
				if ($split_doc_state == 2) {
					$contents .= $1 . "\n";
				} elsif ($split_doc_state == 1) {
					$split_doc_state = 4;
					print STDERR "Warning(${filename}:$.): ";
					print STDERR "Incorrect use of kernel-doc format: $_";
					# ++$warnings;
				}
			}
		}
	}
	close($FILE);

	if ($initial_section_counter == $section_counter) {
		#print STDERR "${file}:1: warning: no structured comments found\n";
	}

	if (!$clean) {
		if ($brief) {
			foreach my $rep (report_dump()) {
				print "$filename: $rep";
			}
		} else {
			print "$filename:\n";
			print " " x 4, join(" " x 4, report_dump());
		}
	}
	return $clean;
}
<<<<<<< HEAD
=======


$kernelversion = get_kernel_version();

# generate a sequence of code that will splice in highlighting information
# using the s// operator.
for (my $k = 0; $k < @highlights; $k++) {
    my $pattern = $highlights[$k][0];
    my $result = $highlights[$k][1];
#   print STDERR "scanning pattern:$pattern, highlight:($result)\n";
    $dohighlight .=  "\$contents =~ s:$pattern:$result:gs;\n";
}

# Read the file that maps relative names to absolute names for
# separate source and object directories and for shadow trees.
if (open(SOURCE_MAP, "<.tmp_filelist.txt")) {
	my ($relname, $absname);
	while(<SOURCE_MAP>) {
		chop();
		($relname, $absname) = (split())[0..1];
		$relname =~ s:^/+::;
		$source_map{$relname} = $absname;
	}
	close(SOURCE_MAP);
}

my @files_to_process = @ARGV;
if ($recursive == 1) {
	@files_to_process = split(/\n/, `find . -name "*.c" -o -name "*.h"`);
	if (scalar @files_to_process == 0) {
		my $exec_name = basename($P);
		print "$exec_name: no input files\n";
		exit(1);
	}
}

foreach (@files_to_process) {
    chomp;
    process_file($_);
}
if ($verbose && $errors) {
  print STDERR "$errors errors\n";
}
if ($verbose && $warnings) {
  print STDERR "$warnings warnings\n";
}

exit(($errors > 0 || $warnings > 0));
>>>>>>> master
