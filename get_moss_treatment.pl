#!/usr/bin/perl
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
$query = new CGI;                        # create new CGI object
use BerkeleyDB;
$today=localtime();
$data_path	="/usr/local/web/ucjeps_data/ucjeps_data";
$dbm_file="$data_path/NORRIS_TREATMENTS";
        tie %NORRIS_treatment, "BerkeleyDB::Hash",
                -Filename => $dbm_file,
                -Flags => DB_CREATE
        or die "Cannot open file $dbm_file: $! $BerkeleyDB::Error\n" ;

if ($query->param('taxon')){
	$taxon=$query->param('taxon');
($kml_taxon=$taxon)=~s/ /_/;
($genus=$taxon)=~s/ .*//;
$genus_key="/general.html#$genus";
	print $query->header;
print <<EOP;
<html>
<head>
<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>California Moss eFlora treatment for $taxon</title>
<meta name="keywords" content="mosses, bryophytes, moss flora. Dan Norris" >
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script type="text/javascript">
function initialize() {
  var myOptions = {
    mapTypeId: google.maps.MapTypeId.TERRAIN
  }

var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);


  var kmlLayer = new google.maps.KmlLayer("http://herbaria4.herb.berkeley.edu/moss_coords/${kml_taxon}.kml?$$", { });
  kmlLayer.setMap(map);

}

function JumpToIt(list) {
    var newPage = list.options[list.selectedIndex].value
    if (newPage != "None") {
        location=newPage
    }
}

</script>

<style type="text/css" media="screen">
    #map_canvas {
      margin-left: auto;
      margin-right: auto;
      display: block;
      float: left;
      width: 490px;
      height: 680px;
      padding: 10px;
    }

</style>
</head>
<body onload="initialize()">
EOP
while(<DATA>){
chomp;
$ital{$_}++;
s/([a-z]) .*/$1/;
$ital{$_}++;
}
$dbm_file="$data_path/MontalvoTable.csv";
open(IN,"$dbm_file") || die "couldnt open $dbm_file\n";
while(<IN>){
chomp;
($name,$null,$filename)=split(/\t/);
$species_name{$name}=$filename;
}


#print "Start";
	open(IN, "$data_path/tnoan_moss.out") || print "tnoan wont open\n";
	while(<IN>){
		chomp;
		($code,$name)=split(/\t/);
		$NTC{$name}=$code;
	}
	$/="";
	$dbm_file="$data_path/MOSS_CAT";
	$lit_file="$data_path/MOSS_LIT";
	use BerkeleyDB;
    	tie %MOSS_CAT, "BerkeleyDB::Hash",
                -Filename => $dbm_file,
		-Flags => RDONLY
        or print "Cannot open file $dbm_file: $! $BerkeleyDB::Error\n" ;
    	tie %MOSS_LIT, "BerkeleyDB::Hash",
                -Filename => $lit_file,
		-Flags => RDONLY
        or print "Cannot open file $lit_file: $! $BerkeleyDB::Error\n" ;
	if($NTC{$taxon}){
		if($MOSS_CAT{$NTC{$taxon}} || $MOSS_CAT{$taxon}){
		$value=$MOSS_CAT{$NTC{$taxon}} || $MOSS_CAT{$taxon};
		if($value=~ s!<PSW>.*(http://cal[^\s]+)\s*(.*)</PSW>\n!!){
			$url=$1;
			$caption=$2;
			unless($caption=~s/[Cc]aption: //){
				$caption=".....";
			}
			if($url=~m!/(\d\d\d\d)_(\d\d\d\d)/(\d\d\d\d)/(\d\d\d\d)!){
				$cpurl="http://calphotos.berkeley.edu/cgi/img_query?enlarge=$1+$2+$3+$4";
			}
			else{
				$cpurl=$url;
			}

                	$image= qq{<a href="$cpurl"><IMG src="$url" width="200"></a>};
        	}

		if($value=~ s!<PSW>.*(http://herbaria4[^ ]+) *(.*)</PSW>\n!!){
			$url=$1;
			$line_caption=$2;
			unless($line_caption=~s/[Cc]aption: //){
				$line_caption="";
			}
			$line_image=qq{<center><img src="http://herbaria4.herb.berkeley.edu/drawings/$species_name{$taxon}" border=1 align="center" width="200"> </center>};
		}
		elsif($species_name{$taxon}){
			$line_image=qq{<center><img src="http://herbaria4.herb.berkeley.edu/drawings/$species_name{$taxon}" border=1 align="center" width="200"> </center>};
		}
		else{
			$line_image="";
		}
if($value=~s/<([a-z0-9]{10})>//){
$maplink=qq{<a href="/cgi-bin/display_map_in_frame.pl?hcode=$1&taxon=$taxon"><img src="http://ucjeps.berkeley.edu/cgi-bin/draw_tiny2.pl?$1" border="0" alt="map of distribution"></a>};
}
else{
$maplink="";
}
foreach($value){
if(s/(<a href.*Previous<\/a>)//){
$previous=$1;
}
if(s/(<a href.*Next<\/a>)//){
$next=$1;
}
else{
$next="";
}
s! (Norris|Shevock|Wilson) (\d\d\d+) & (\d\d\d+)! <a href="http://ucjeps.berkeley.edu/cgi-bin/get_bex.pl?collector=$1&coll_num=$2">$1 $2</a> & <a href="http://ucjeps.berkeley.edu/cgi-bin/get_bex.pl?collector=$1&coll_num=$3"> $3</a>!g;
s! (Norris|Shevock)( & [A-Z][a-z]+ )(\d\d\d\d\d+)! <a href="http://ucjeps.berkeley.edu/cgi-bin/get_bex.pl?collector=$1&coll_num=$3">$1$2 $3</a>!g;
s! (Norris|Shevock) (\d\d\d\d\d+)! <a href="http://ucjeps.berkeley.edu/cgi-bin/get_bex.pl?collector=$1&coll_num=$2">$1 $2</a>!g;
#s! ([A-Z][a-z]+ and [A-Z][a-z]+ \d\d\d\d[a-z]?);! <a href="/cgi-bin/get_moss_lit.pl?ref=$1">$1</a>;!g;
#s! ([A-Z][a-z]+ \d\d\d\d[a-z]?);! <a href="/cgi-bin/get_moss_lit.pl?ref=$1">$1</a>;!g;
#s/\n/<br>/g;
s/\303\244/&auml;/g;
s/\303\266/&ouml;/g;
s/\303\274/&uuml;/g;
s/\303\251/&eacute;/g;
s/\303\261/&ntilde;/g;
s/\342\200\231/'/g;
}
@values=split(/\n/,$value);
grep(s/^([^:]+): *(.*)/<tr><td valign="top"><b>$1<\/b><\/td><td>$2<\/td><\/tr>/, @values);
foreach(@values){
s/Geographic subdivisions/Bioregions/;
s/Selected specimens/Vouchers/;
}
$values[0]=~s/^.*/<tr><th><\/th><th>$&<\/th><\/tr>/;
if($NORRIS_treatment{$kml_taxon}){
$Norris_treatment= "<blockquote>$NORRIS_treatment{$kml_taxon}</blockquote>";
$Norris_treatment=~s/ ([A-Z]\.)([a-z][a-z][a-z])/ $1 $2/g;
$Norris_treatment=~s/ ([A-Z][a-z]+ [a-z]+)/$ital{$1}?" <i>$1<\/i>":" $1"/ge;
$Norris_treatment=~s/ ([A-Z][a-z]+ [a-z]+)/$ital{$1}?" <i>$1<\/i>":" $1"/ge;
$Norris_treatment=~s/ ([A-Z]\. [a-z]+)/$ital{$1}?" <i>$1<\/i>":" $1"/ge;
$Norris_treatment=~s/ ([A-Z][a-z]+)/$ital{$1}?" <i>$1<\/i>":" $1"/ge;
$Norris_treatment=~s/([A-Z][a-z]+ [a-z]+)/$ital{$1}?"<i>$1<\/i>":" $1"/ge;
}
else{
$Norris_treatment= "$kml_taxon: Species treatment still being edited.";
}
foreach($Norris_treatment){
s/\303\244/&auml;/g;
s/\303\266/&ouml;/g;
s/\303\274/&uuml;/g;
s/\303\251/&eacute;/g;
s/\303\261/&ntilde;/g;
s/\342\200\231/'/g;
}
			print<<TREATMENT;




<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"><title>UC Herbarium: Moss eFlora</title> 
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
        <a href="/" class="horizMenuActive">Home</a>	
    </td>

<td>
  </td></tr>
   <tr>
       <td colspan="6" bgcolor="#9FBFFF"><img src="http://ucjeps.berkeley.edu/common/images/common_spacer.gif" alt="" width="1" height="1" border="0"></td>
     </tr>
 </tbody></table>





<table border=0 bgcolor="#eeeeee" cellpadding=10 width="100%">
<tr>
<td colspan=2>
<center>
       <span class="pageName"><font size="5">California Moss eFlora</font></span>
</center>
$previous 
<font size="2">
/
</font>
$next
  <p class="bodyText"><a href="/CA_moss_eflora/">Home</a> &middot;
      <a href="/CA_moss_eflora/moss_gl.html">List of Genera</a> &middot;
      <a href="/CA_moss_eflora/general.html">Key to Keys</a> &middot;
      <a href="/CA_moss_eflora/moss_appendix.html">Accepted Names</a> &middot;
      <a href="/CA_moss_eflora/moss_appendix_IV.html">Synonyms</a> &middot;
      <a href="/CA_moss_eflora/moss_beginner.html">For Beginners</a> &middot;
See also ....
  <a href="http://ucjeps.berkeley.edu/IJM_geography.html">Subdivisions of CA</a>
&nbsp;&mdash;&nbsp;
  <a href="http://ucjeps.berkeley.edu/IJM.html">Jepson eFlora for CA Vascular Plants</a> 
&nbsp;&mdash;&nbsp;
<a href="http://ucjeps.berkeley.edu/cgi-bin/get_bex.pl?county=&source=All&taxon_name=$taxon">Specimen records</a>
&nbsp;&mdash;&nbsp;
<a href="#elev_map">Elevation by latitude plot</a>
&nbsp;&mdash;&nbsp;
<a href="http://www.tropicos.org/Name/$NTC{$taxon}">Tropicos nomenclature</a>
&nbsp;&mdash;&nbsp;
<a href="http://calphotos.berkeley.edu/cgi/img_query?&where-genre=Plant&where-taxon=$taxon">Cal Photos images</a>
&nbsp;&mdash;&nbsp;
<a href="http://www.efloras.org/browse.aspx?flora_id=50&name_str=$taxon&btnSearch=Search">Bryophyte  Flora of North America</a>
&nbsp;&mdash;&nbsp;
<a href="http://scholar.google.com/scholar?hl=en&lr=&q=$taxon+&btnG=Search">Google Scholar</a>
</P>
</td></tr>

$values[0]
<table align="center" BGCOLOR="#eeeeee" cellspacing=10 width="20%">
<tr>
<td align="center">$maplink</td>
<td align="center">$image</td>
<td align="center">$line_image</td>
</tr>
<tr>
<td></td><td align="center"><font size="2">$caption</font></td><td><font size="2">$line_caption</font></td>
</tr>
</table>
$Norris_treatment
<a href="mailto:paul.wilson\@csun.edu?subject=$taxon">Mail a correction to Paul Wilson</a>

<table>
@values[1..$#values]
</table>
</td>
</tr>
<tr>
<td>

<!-- <table>
<tr><td> -->
<!-- $maplink -->
		<div id="map_canvas"></div>
<!-- </td>
		<td> -->
&nbsp; &nbsp;
		<a name="elev_map">
		<img src="http://ucjeps.berkeley.edu/cgi-bin/map_BEX_elev.pl?&taxon_name=$taxon"> </a>
		<h3>Elevation by latitude plot for $taxon<br>&nbsp;&nbsp;&nbsp;in California</h3>
<!-- </td></tr></table> -->



</td>
</tr>
</table>

TREATMENT
		}
else{
print "No Catalog entry for for $taxon";
}
	}
	else{
		print<<EOP;
<h2>No code for $taxon
Sorry for inconvenience.</h2>

EOP
}
}
print <<EOP;
Copyright &copy; 2013 Regents of the University of California 
<br>
We encourage links to these pages, but the content may not be downloaded for reposting, repackaging, redistributing, or sale in any form, without written permission from the University and Jepson Herbaria.
<br>
Generated $today

</body>
</html>
EOP
__END__
A. androgynum
A. bifrons
A. californica
A. californicum
A. curtipendula
A. laevisphaera
A. lapponicum
A. menziesii
A. mougeotii
A. palustre
Acaulon muticum
Acaulon rufescens
Acaulon triquetrum
Aloina bifrons
Aloina rigida
Alsia californica
Alsia longipes
Amblystegium molle
Amphidium californicum
Amphidium cyathicarpum
Amphidium lapponicum
Amphidium mougeotii
Anacolia baueri
Anacolia californica
Anacolia menziesii
Andreaea rupestris
Anictangium ciliatum
Anictangium flaccidum
Anictangium lapponicum
Anoectangium anomalum
Antitrichia californica
Antitrichia curtipendula
Antitrichia gigantea
Arctoa blyttii
Arctoa falcata
Arctoa fulvella
Arctoa starkei
Aulacomnium androgynum
Aulacomnium palustre
B. algovicum
B. alpinum
B. angustirete
B. aphylla
B. argenteum
B. bicolor
B. bimum
B. blindii
B. caespiticium
B. canariense
B. capillare
B. cernuum
B. cirrhatum
B. crassirameum
B. creberrimum
B. cuspidatum
B. cyclophyllum
B. flaccidum
B. gemmascens
B. gemmilucens
B. gemmiparum
B. inclinatum
B. ithyphylla
B. leibergii
B. lisae
B. lonchocaulon
B. meesioides
B. miniatum
B. muehlenbeckii
B. pallens
B. pallescens
B. pendulum
B. piperi
B. plumosum
B. pomiformis
B. pseudotriquetrum
B. rubens
B. sandbergii
B. stenotrichum
B. stricta
B. tenuisetum
B. torquescens
B. tortifolium
B. turbinatum
B. uliginosum
B. violaceum
B. viridis
B. weigelii
Barbula aciphylla
Barbula elongate
Barbula iocmsdophila
Barbula obtusissima
Barbula pagorum
Barbula papillosissima
Barbula princeps
Barbula rigidula
Barbula rubiginosa
Barbula rufipila
Barbula ruralis
Barbula subulata
Barbula tophaceus
Barbula umbrosa
Barbula vinealis
Bartramia circinnulata
Bartramia glauco-viridis
Bartramia ithyphylla
Bartramia menziesii
Bartramia pomiformis
Bartramia stricta
Bartramia vulgaris
Benitotania leucomioides
Blindia acuta
Brachythecium albicans
Brachythecium asperrimum
Brachythecium bolanderi
Brachythecium collinum
Brachythecium curtum
Brachythecium erythrorrhizon
Brachythecium fendleri
Brachythecium frigidum
Brachythecium holzingeri
Brachythecium hylotapetum
Brachythecium laevisetum
Brachythecium latifolium
Brachythecium leibergii
Brachythecium nanopes
Brachythecium nelsoni
Brachythecium nelsonii
Brachythecium oedipodium
Brachythecium operculum
Brachythecium plumosum
Brachythecium populeum
Brachythecium reflexum
Brachythecium rivulare
Brachythecium rutabuliforme
Brachythecium rutabulum
Brachythecium salebrosum
Brachythecium starkei
Brachythecium turgidum
Brachythecium velutinum
Brachythecium venustum
Branched filaments
Braunia californica
Bruchia bolanderi
Bryhnia bolanderi
Bryolawtonia vancouveriensis
Bryum algovicum
Bryum androgynum
Bryum capillare
Bryum flavescens
Bryum fulvellum
Bryum nudum
Bryum patens
Buxbaumia aphylla
Buxbaumia piperi
Buxbaumia viridis
C. bolanderi
C. crispifolium
C. purpureus
C. stenocarpus
C. whippleanum
Callicladium haldanianum
Camptothecium amesiae
Camptothecium aureum
Camptothecium pinnatifidum
Campylopus introflexus
Campylopus laevigatus
Campylostelium saxicola
Ceratodon purpureus
Claopodium bolanderi
Claopodium crispifolium
Claopodium whippleanum
Codriophorus acicularis
Codriophorus depressus
Codriophorus fascicularis
Codriophorus hypericum
Crumia deciduidentata
Crumia latifolia
Cuticle separating
Cynodontium trifarius
Cynodontium vairens
Cynodontium wahlenbergii
D. abietina
D. australasiae
D. falcatum
D. fuscescens
D. norrisii
D. olympicum
D. rigidulus
D. sulcatum
D. uncinatum
D. vinealis
D. viridulus
Dendroalsia abietina
Desmatodon guepinii
Dichelyma falcatum
Dichelyma uncinatum
Dichodontium flavescens
Dichodontium olympicum
Dichodontium pellucidum
Dicranoweisia cirrata
Dicranoweisia contermina
Dicranoweisia crispula
Dicranoweisia subcompacta
Dicranum aciculare
Dicranum contortum
Dicranum elongatum
Dicranum falcatum
Dicranum fuscescens
Dicranum hispidulum
Dicranum howellii
Dicranum introflexum
Dicranum ovale
Dicranum purpureum
Dicranum saxicola
Dicranum scoparium
Dicranum starkei
Dicranum strictum
Dicranum sulcatum
Dicranum tauricum
Dicranum virens
Didymodon australasiae
Didymodon brachyphyllus
Didymodon diaphanobasis
Didymodon hendersonii
Didymodon icmadophila
Didymodon luridus
Didymodon nicholsonii
Didymodon norrisii
Didymodon occidentalis
Didymodon revolutus
Didymodon rigidulus
Didymodon tophaceus
Didymodon umbrosus
Didymodon vinealis
Differentiated elongate
Discelium nudum
Ditrichum ambiguum
Doklichotheca seligeri
Doklichotheca striatella
Dolichotheca pilifera
Dorcadion laevigatum
Dorcadion lyellii
Dorcadion obtusifolium
Dorcadion pallens
Dorcadion pulchellum
Dorcadion rupestre
Dryptodon anomalus
Dryptodon patens
Encalypta ciliata
Ephemerum serratum
F. antipyretica
F. duriae
F. howellii
F. hypnoides
F. patula
Fabronia pusilla
Fissidens adianthoides
Fissidens aphelotaxifolius
Fissidens bryoides
Fissidens crispus
Fissidens debilis
Fissidens fontanus
Fissidens grandifrons
Fissidens julianus
Fissidens limbatus
Fissidens milobakeri
Fissidens pauperculus
Fissidens sublimbatus
Fissidens ventricosus
Fontinalis antipyretica
Fontinalis duriae
Fontinalis howellii
Fontinalis hypnoides
Fontinalis juliana
Fontinalis kindbergii
Fontinalis patula
G. reflexidens
Glyphocarpa baueri
Grimmia affinis
Grimmia agassizii
Grimmia alpestris
Grimmia alpicola
Grimmia anomala
Grimmia apocarpa
Grimmia arizonae
Grimmia brevirostris
Grimmia caespiticia
Grimmia campestris
Grimmia catalinensis
Grimmia cinclidontea
Grimmia commutata
Grimmia conferta
Grimmia contorta
Grimmia curvata
Grimmia elatior
Grimmia hamulosa
Grimmia hartmanii
Grimmia incurva
Grimmia kindbergii
Grimmia laevigata
Grimmia leibergii
Grimmia leucophaea
Grimmia lisae
Grimmia longirostris
Grimmia mariniana
Grimmia maritima
Grimmia montana
Grimmia moxleyi
Grimmia nevadensis
Grimmia nevii
Grimmia occidentalis
Grimmia orbicularis
Grimmia ovalis
Grimmia ovata
Grimmia pacifica
Grimmia patens
Grimmia philibertiana
Grimmia plagiopodia
Grimmia platyphylla
Grimmia poecilostoma
Grimmia pulvinata
Grimmia ramondii
Grimmia rivularis
Grimmia sarcocalyx
Grimmia serrana
Grimmia sessitana
Grimmia shastae
Grimmia sp
Grimmia tenerrima
Grimmia torenii
Grimmia torquata
Grimmia uncinata
Grimmia unicolor
Grimmia vaginata
Gymnostomum aeruginosum
Gymnostomum calcareum
Gymnostomum recurvirostre
H. acutifolia
H. ciliata
H. detonsa
H. lucens
H. pinnatifidum
H. recurvirostre
H. splendens
H. stellata
Haplocladium microphyllum
Hedwigia ciliata
Hedwigia detonsa
Hedwigia stellata
Herzogiella seligeri
Herzogiella striatella
Heterocladium heteropteroides
Heterocladium macounii
Heterophyllium haldanianum
Homalothecium aureum
Homalothecium decurrentifolium
Homalothecium nuttallii
Homalothecium pinnatifidum
Hookeria acutifolia
Hookeria lucens
Husnotiella palmeri
Husnotiella revoluta
Husnotiella torquescens
Hygrohypnum alpinum
Hygrohypnum bestii
Hygrohypnum dilatatum
Hygrohypnum duriusculum
Hygrohypnum luridum
Hygrohypnum molle
Hygrohypnum ochraceum
Hygrohypnum smithii
Hygrohypnum styriacum
Hylocomium flemingii
Hylocomium loreum
Hylocomium robustum
Hylocomium splendens
Hylocomium squarrosum
Hylocomium subg
Hylocomium triquetrum
Hymenostylium recurvirostre
Hypnum bigelovii
Hypnum bolanderi
Hypnum borrerianum
Hypnum brewerianum
Hypnum canadense
Hypnum circinale
Hypnum columbico-palustre
Hypnum crispifolium
Hypnum cupressiforme
Hypnum curtum
Hypnum denticulatum
Hypnum dieckii
Hypnum dilatatum
Hypnum fitzgeraldii
Hypnum haldanianum
Hypnum jungermannioides
Hypnum leibergii
Hypnum loreum
Hypnum lucens
Hypnum luridum
Hypnum microphyllum
Hypnum molle
Hypnum neckeroides
Hypnum ochraceum
Hypnum oedipodium
Hypnum pinnatifidum
Hypnum plumosum
Hypnum populeum
Hypnum pseudo-recurvans
Hypnum pseudoarcticum
Hypnum ramulosum
Hypnum reflexum
Hypnum revolutum
Hypnum robustum
Hypnum rutabulum
Hypnum salebrosum
Hypnum sequoieti
Hypnum spiculiferum
Hypnum splendens
Hypnum squarrosum
Hypnum styriacum
Hypnum subimponens
Hypnum subtenue
Hypnum touretii
Hypnum triquetrum
Hypnum undulatum
Hypnum watsoni
Hypnum whippleanum
I. myosuroides
Isopterygium borreri
Isopterygium elegans
Isopterygium piliferum
Isopterygium pulchellum
Isopterygium seligeri
Isopterygium striatellum
Isothecium aureum
Isothecium elegans
Isothecium howei
Isothecium myosuroides
Isothecium spiculiferum
Isothecium stoloniferum
K. glacialis
K. praelonga
Larger stem
Leptodon circinatus
Leptohymenium cristatum
Leskea julacea
Leskea pilifera
Leskea pulchella
Leskea seligeri
Leskea smithii
Leskea striatella
Limbidium unistratose
Limnobium duriusculum
Loeske ssp
Meesia trifaria
Meesia triquetra
Meesia tristicha
Meesia uliginosa
Merceya latifoia
Metaneckera menziesii
Mnium fontanum
Mnium glabrescens
Mnium insigne
Mnium nudum
Mnium triquetrum
Myurella julacea
Myurella tenerrima
Neckera abietina
Neckera californica
Neckera douglasii
Neckera menziesii
Neckeradelphus menziesii
Normal plication
Nyholmiella obtusifolium
O. diaphanum
O. epapillosum
O. flowersii
O. hallii
O. laevigatum
O. lyellii
O. papillosum
O. rivulare
O. speciosum
O. striatum
O. tenellum
Octodiceras fontanum
Octodiceras julianum
Oncophorus virens
Onocphorus wahlenbergii
Orthodicranum strictum
Orthotrichum affine
Orthotrichum alpestre
Orthotrichum arcticum
Orthotrichum blyttii
Orthotrichum bolanderi
Orthotrichum brachytrichum
Orthotrichum bullatum
Orthotrichum columbicum
Orthotrichum consimile
Orthotrichum coulteri
Orthotrichum cupulatum
Orthotrichum cylindrocarpum
Orthotrichum diaphanum
Orthotrichum epapillosum
Orthotrichum euryphyllum
Orthotrichum fallax
Orthotrichum flowersii
Orthotrichum garrettii
Orthotrichum hainesiae
Orthotrichum hallii
Orthotrichum hendersonii
Orthotrichum idahense
Orthotrichum inflexum
Orthotrichum jamesianum
Orthotrichum jamesii
Orthotrichum kingianum
Orthotrichum laevigatum
Orthotrichum leiodon
Orthotrichum lyellii
Orthotrichum lyellioides
Orthotrichum macfaddenae
Orthotrichum macounii
Orthotrichum microblephare
Orthotrichum microblepharum
Orthotrichum obtusifolium
Orthotrichum occidentale
Orthotrichum pallens
Orthotrichum papillosum
Orthotrichum pellucidum
Orthotrichum praemorsum
Orthotrichum pringlei
Orthotrichum pulchellum
Orthotrichum pumilum
Orthotrichum pylaesii
Orthotrichum pylaisii
Orthotrichum raui
Orthotrichum rhabdophorum
Orthotrichum rivulare
Orthotrichum roellii
Orthotrichum rupestre
Orthotrichum speciosum
Orthotrichum spjutii
Orthotrichum stenocarpum
Orthotrichum striatum
Orthotrichum subsordidum
Orthotrichum tenellum
Orthotrichum texanum
Orthotrichum ulotaeforme
Orthotrichum utahense
Orthotrichum watsoni
Outer cortical
Outlying populations
P. americana
P. catenulata
P. de
P. fontana
P. insigne
P. medium
P. piliferum
P. venustum
Phascum cuspidatum
Phascum hyalinotrichum
Phascum subulatum
Phascum triquetrum
Philonotis fontana
Physcomitrium rhizophyllum
Plagiomnium insigne
Plagiotheciella pilifera
Plagiothecium denticulatum
Plagiothecium elegans
Plagiothecium laetum
Plagiothecium piliferum
Plagiothecium pulchellum
Plagiothecium schimperi
Plagiothecium seligeri
Plagiothecium striatellum
Plagiothecium undulatum
Platydictya jungermannioides
Pleuridium bolanderi
Pleuridium subulatum
Porothamnium bigelovii
Porotrichum bigelovii
Porotrichum neckeroides
Pseudisothecium stoloniferum
Pseudobraunia californica
Pseudoleskeella serpentinense
Pterigynandrum tenerrimum
Pterogonium gracile
Racomitrium aciculare
Racomitrium depressum
Racomitrium fasciculare
Racomitrium hypericum
Racomitrium submarginatum
Rhacomitrium microcarpum
Rhacomitrium patens
Rhizomnium glabrescens
Rhizomnium known
Rhizomnium nudum
Rhynchostegium obtusifolium
Rhytidiadelphus loreus
Rhytidiadelphus squarrosus
Rhytidiadelphus triquetrus
Rhytidiopsis robusta
Roellia roellii
S. platyphyllum
Schistidium agassizii
Schistidium alpicola
Schistidium alpicolum
Schistidium apocarpum
Schistidium atrichum
Schistidium cinclidodonteum
Schistidium confertum
Schistidium dupretii
Schistidium flaccidum
Schistidium maritimum
Schistidium occidentale
Schistidium pacificum
Schistidium plagiopodium
Schistidium platyphyllum
Schistidium pulvinatum
Schistidium rivulare
Schistidium sp
Schistidium splendens
Schistidium squarrosum
Schistidium tenerum
Scleropodium cespitans
Scleropodium illecebrum
Scleropodium obtusifolium
Scleropodium touretii
Scopelophila cataractae
Scopelophila latifolia
Sequoia sempervirens
Sharpiella seligeri
Sharpiella striatella
Sierran foothills
Skitophyllum fontanum
Sporophytes known
Stereodon complexus
Stereodon obtusifolius
Stereodon revolutus
Stereodon undulatus
Stroemia obtusifolia
Submarginal plication
Suboral exothecial
Syntrichia laevipila
Syntrichia norvegica
T. muralis
Tetraphis geniculata
Tetraphis pellucida
Thamnbobryum neckeroides
Thamnium bigelovii
Thamnium neckeroides
Thamnium vancouveriensis
Thamnobryum bigelovii
Thamnobryum leibergii
Tortula australasiae
Tortula bifrons
Tortula laevipila
Tortula muralis
Tortula norvegica
Tortula obtusissima
Tortula pagorum
Tortula papillosissima
Tortula princeps
Tortula rhizophylla
Tortula ruralis
Tortula subulata
Tortula vectensis
Trichostomopsis australasiae
Trichostomopsis brevifolia
Trichostomopsis diaphanobasis
Trichostomopsis fayae
Trichostomopsis umbrosa
Trichostomum fasciculare
Tripterocladium brewerianum
Ulota alaskana
Ulota crispa
Ulota maritima
Ulota megalospora
Ulota obtusiuscula
Ulota phyllantha
Ulota reptans
Ulota subulata
Ulota subulifolia
Weissia acuta
Weissia cirrata
Weissia crispula
Zygodon baumgartneri
Zygodon californicus
Zygodon mougeotii
Zygodon rupestris
Zygodon viridissimus
Zygodon vulgaris
