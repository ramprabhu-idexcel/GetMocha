<?php
/**
 * Customizable Global Header Include
 *
 * @author Nathan Wright <nathan@simplestation.com>
 */

$defaultTitle = 'Mocha';
$defaultBodyClass = '';
$defaultMeta = array(
	'keywords' => '',
	'description' => '',
	'robots' => 'INDEX,FOLLOW'
);


/**
 * XHTML 1.0 doctype variants are all supported.
 * Allowed values: Transitional, Frameset or Strict
 */
$defaultDoctype = 'Strict';
$doctype = isset($doctype) && in_array($doctype, array('Transitional', 'Frameset', 'Strict')) ? $doctype : $defaultDoctype;

/**
 * Javascript and CSS can be added by setting any of the following (prior to
 * including this file):
 *
 *     $headJs = '/global/js/asdf.js'; // or..
 *     $headJs = array('/global/js/asdf.js',
 *                     '/global/js/qwerty.js');
 *
 *     $headCss = '/global/css/asdf.css'; // or..
 *     $headCss = array('/global/css/asdf.css',
 *                      '/global/css/qwerty.css');
 */
$headCss = isset($headCss) ? (array) $headCss : array();
$headJs = isset($headJs) ? (array) $headJs : array();

/**
 * Define any <meta> tags you like. name => content.
 * Meta tags with an empty string for a value are not rendered.
 */
$headMeta = isset($headMeta) ? (array) $headMeta : array();
$headMeta += $defaultMeta;

/**
 * The <title> tag is handled intelligently. A title is specified but doesn't
 * mention 'CoThink.it' anywhere, it's appended. Otherwise we just leave it.
 */
$headTitle = isset($headTitle) ? (string) $headTitle : '';

if (!$headTitle) {
	// If no title is provided, set the default
	$headTitle = $defaultTitle;
} elseif (strpos($headTitle, $defaultTitle) === false) {
	// If we are given a title append ' | CoThink.it' if not mentioned already
	$headTitle .= ' | ' . $defaultTitle;
}

/**
 * Append arbitrary XHTML to the head by passing a string to $headExtra
 */
$headExtra = isset($headExtra) ? (string) $headExtra : '';

/**
 * Define a custom <body class="">
 * Value can be a string or array of CSS class names.
 */
$bodyClass = isset($bodyClass) ? $bodyClass : $defaultBodyClass;
$bodyClass = is_array($bodyClass) ? implode(' ', $bodyClass) : (string) $bodyClass;

/**
 * Body IDs may be defined if need be but classes are preferred.
 */
$bodyId = isset($bodyId) ? (string) $bodyId : '';

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 <?php echo ucfirst($doctype) ?>//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-<?php echo strtolower($doctype) ?>.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head profile="http://gmpg.org/xfn/11">
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title><?php echo $headTitle ?></title>

	<?php foreach ($headMeta as $headMetaName => $headMetaValue): if ($headMetaValue != ''): ?>
		<meta name="<?php echo $headMetaName ?>" content="<?php echo $headMetaValue ?>" />
	<?php endif; endforeach; ?>

	<?php if (!isset($skipTop) && $skipTop): ?>
		<link href="/styles/base.css" media="screen" rel="stylesheet" type="text/css" />
	<?php endif; ?>
	<?php foreach ($headCss as $url): ?>
		<link rel="stylesheet" href="<?php echo $url ?>" type="text/css" media="screen" />
	<?php endforeach ?>
	<!--[if lte IE 9]>
		<link rel="stylesheet" type="text/css" href="/marketing/styles/ie.css" />
	<![endif]-->

	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js"></script> 
	<script type="text/javascript" src="/marketing/scripts/third-party/jquery.easing.1.3.js"></script> 
	<script type="text/javascript" src="/marketing/scripts/third-party/jquery.easing.compatibility.js"></script>

	<?php foreach ($headJs as $url): ?>
		<script type="text/javascript" src="<?php echo $url ?>"></script>
	<?php endforeach ?>

	<!--[if lt IE 7]>
	<script src="http://ie7-js.googlecode.com/svn/version/2.0(beta3)/IE7.js" type="text/javascript"></script>
	<![endif]-->

	<!--[if IE 6]>
	<script type="text/javascript">
		// Load jQuery if not already loaded
		if (typeof jQuery == 'undefined') {
			document.write('<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></'+'script>');
			var __noconflict = true;
		}
		var IE6UPDATE_OPTIONS = {icons_path: '/scripts/third-party/ieupdate/images/'};
	</script>
	<script src="/scripts/third-party/ieupdate/ie6update.js" type="text/javascript"></script>
	<![endif]-->

	<?php echo $headExtra ?>

	<!--<link rel="shortcut icon" href="/images/favicon.ico" />-->
</head>

<body class="<?= $bodyClass ?>"<?php if ($bodyId) echo ' id="' . $bodyId . '"' ?>>

<?php
if (!isset($skipTop) && $skipTop) {
	include $_SERVER['DOCUMENT_ROOT'] . '/includes/top.php';
}
?>

<div class="wrapper">

<div class="header">
	<div class="container-960">
		<a href="/marketing/" class="logo">Mocha</a>
		<ul class="nav">
			<li>
				<a href="/marketing/login">
					<span class="left"></span>
					<span class="middle">Log in</span>
					<span class="right"></span>
				</a>
			</li>
			<li>
				<a href="/marketing/signup">
					<span class="left"></span>
					<span class="middle">Sign Up</span>
					<span class="right"></span>
				</a>
			</li>	
			<li>
				<a href="/marketing/faq">
					<span class="left"></span>
					<span class="middle">Support</span>
					<span class="right"></span>
				</a>
			</li>
			<!--<li>
				<a href="/marketing/about">
					<span class="left"></span>
					<span class="middle">About</span>
					<span class="right"></span>
				</a>
			</li>-->
		</ul>
	</div>
	
	<div class="header-highlight"></div>
	<div class="header-bottom"></div>
	<div class="pages"></div>
</div>

