#!/usr/bin/perl
use CGI;
$query = new CGI;                        # create new CGI object
use BerkeleyDB;
$data_path	="/usr/local/web/ucjeps_data/ucjeps_data";
$dbm_file="$data_path/MOSS_GENUS_KEY_HASH";
        tie %GEN_KEYS, "BerkeleyDB::Hash",
                -Filename => $dbm_file,
                -Flags => DB_CREATE
        or die "Cannot open file $dbm_file: $! $BerkeleyDB::Error\n" ;

if ($query->param('genus')){
	$taxon=$query->param('genus');
	print $query->header;
#print <<EOP;
#<html>
#<head>
#<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
#<title>Tier 1 key to $taxon</title>
#
#<style type="text/css" media="screen">
    ##map_canvas {
      #margin-left: auto;
      #margin-right: auto;
      #display: block;
      #float: left;
      #width: 490px;
      #height: 680px;
      #padding: 10px;
    #}

#</style>
#</head>
#EOP
if($GEN_KEYS{$taxon}){
#<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"><title>UC Herbarium: Moss eFlora Tier 1 key to $taxon</title> 
print <<EOP;
<html xmlns="http://www.w3.org/1999/xhtml"><head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><title>California Moss eFlora key to $taxon</title> 

<link href="http://ucjeps.berkeley.edu/common/styles/style_main_tjm2.css" rel="stylesheet" type="text/css">
</head>

<body class="bodyText">

<!-- Begin banner -->
<table class="banner" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tbody><tr>
      <td colspan="5" align="center" valign="middle">&nbsp;</td>
    </tr>

  <tr>
      <td rowspan="4" width="12" align="center" valign="middle"></td>
      <td rowspan="3" width="120" align="center" valign="middle">
        <a href="http://ucjeps.berkeley.edu/uc/"><img src="http://ucjeps.berkeley.edu/common/images/logo_uc_80.png" alt="University of California [UC]" width="80" height="79" border="0"></a></td>
    <td align="center">&nbsp;</td>
    <td rowspan="3" width="120" align="center" valign="middle"></td>
    <td rowspan="4" width="12" align="center" valign="middle"></td>
  </tr>
    <tr>

    <td align="center" valign="middle"><span class="bannerTitle">University Herbarium</span><br></td>
  </tr>

    <tr>
     <td align="center" valign="top"><a href="http://www.berkeley.edu/" class="bannerTagLine">University of California, Berkeley</a></td>
   </tr>

     <tr>
     <td colspan="3" align="center"></td>

   </tr>
     
   <tr>
       <td height="8" colspan="5" align="center">&nbsp;</td>
     </tr>
   <tr class="bannerBottomBorder">
     	<td colspan="6" height="3"></td>
  </tr>

    <tr>

    <td colspan="6"><img src="http://ucjeps.berkeley.edu/common/images/common_spacer.gif" alt="" width="1" height="1" border="0"></td>
  </tr>
  </tbody></table>
  <!-- End banner -->

  <!-- Beginning of horizontal menu -->
  <table class="horizMenu" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tbody><tr>
    <td height="21" width="640" align="right">

      <a href="http://ucjeps.berkeley.edu/main/directory.html" class="horizMenuActive">Directory</a>
  	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <a href="http://ucjeps.berkeley.edu/news/" class="horizMenuActive">News</a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <a href="http://ucjeps.berkeley.edu/main/sitemap.html" class="horizMenuActive">Site Map</a>	
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <a href="http://ucjeps.berkeley.edu/" class="horizMenuActive">Home</a>	
    </td>

<td>
  </td></tr>
   <tr>
       <td colspan="6" bgcolor="#9FBFFF"><img src="http://ucjeps.berkeley.edu/common/images/common_spacer.gif" alt="" width="1" height="1" border="0"></td>
     </tr>
 </tbody></table>







 <!-- End of horizontal menu -->
<center>
<p>
       <span class="pageName"><font size="5">California Moss eFlora</font></span>
</p>
</center>




<table align="center" width="100%">
</table>
<p></p><table border="0">
<tbody><tr><td>
      <a href=""> Jan  1 2013 </a> &middot;
  <p class="bodyText"><a href="/CA_moss_eflora">Home</a> &middot;
      <a href="/CA_moss_eflora/moss_gl.html">List of Genera</a> &middot;
      <a href="/CA_moss_eflora/general.html">Key to Keys</a> &middot;
      <a href="/CA_moss_eflora/moss_appendix.html">Accepted Names</a> &middot;
      <a href="/CA_moss_eflora/moss_appendix_IV.html">Synonyms</a> &middot;
      <a href="/CA_moss_eflora/moss_beginner.html">For Beginners</a> &middot;
  <a href="http://ucjeps.berkeley.edu/IJM_geography.html">Subdivisions of CA</a> &middot;
  <a href="http://ucjeps.berkeley.edu/IJM.html">Jepson eFlora for CA Vascular Plants</a><br>
<a href="mailto:paul.wilson\@csun.edu?subject=$taxon">Mail a comment to Paul Wilson</a>
</p>
</td>
</tr>
</table>

EOP
$ToBePrinted= $GEN_KEYS{$taxon};
foreach($ToBePrinted){
s/\303\205/&Aring;/g;
s/\303\244/&auml;/g;
s/\303\266/&ouml;/g;
s/\303\274/&uuml;/g;
s/\303\251/&eacute;/g;
s/\303\261/&ntilde;/g;
s/\342\200\231/'/g;
s/\342\200\223/&mdash;/g;
}
print $ToBePrinted;
}
else{
	print $query->header;
print "I cant find a key for $taxon";
}
}
else{
	print $query->header;
print "You must select one of the genus names, thanks.";
}
print <<EOP;
Copyright &copy; 2013 Regents of the University of California 
<br>
We encourage links to these pages, but the content may not be downloaded for reposting, repackaging, redistributing, or sale in any form, without written permission from the University and Jepson Herbaria.

</body>
</html>
EOP
