all:
	fatpack trace `which patchperl`
	fatpack packlists-for `cat fatpacker.trace` >packlists
	fatpack tree `cat packlists`
	(echo "#!/usr/bin/env perl"; fatpack file; cat `which patchperl`) > patchperl
	chmod +x patchperl


