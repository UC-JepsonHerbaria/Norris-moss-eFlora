#!/usr/bin/perl
use CGI;
use BerkeleyDB;
$q=new CGI;
@refs=$q->param('ref');
grep(s/ //g,@refs);
tie(%refhash, "BerkeleyDB::Hash", -Filename=>"/Users/rlmoe/MOSS_FLORA/MOSS_LIT", -Flags=>DB_RDONLY)|| do{
       print $q->header,                    # create the HTTP header
            $q->start_html('Hash lookup error'),
            $q->h1('File path_gen not found'),
             $q->end_html;                  # end the HTML
die;
};

      print $q->header,
            $q->start_html('List of references'),
	$q->h6({-align=>center},
	'<a href="http://ucjeps.berkeley.edu/index.html">University Herbarium, UC Berkeley</a>'),
	$q->h2({-align=>center},
	'California Bryoflora'),
	    $q->h3('Literature list');




print "<IMG SRC=\"/icons/folder.open.gif\" ALT=\"\">$hstring<br>";
foreach (sort(@refs)){
local($_)=$refhash{$_};
next if $seen{$_}++;
s/Madro..o/Madro&ntilde;o/;
print "$_";
}
             print $q->end_html;                  # end the HTML
