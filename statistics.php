<html>
	<head>
		<title>Datapedia</title>
		
		<?php 
			if($_GET['N'] !== '' && $_GET['N'] !== NULL){
			$N = $_GET['N'];
			exec("Rscript searchTwitter.R $N",$response);
			$str = $response[1];
			$myobj = json_decode($str);
			}
			else if($_GET['H'] !== '' && $_GET['H'] !== NULL){
			$H = $_GET['H'];
 			exec("Rscript bigSearchTwitter.R $H",$response);
			foreach ($response as &$str) {
				if (strpos($str,'"') !== false) {
  				$res = $res.$str;
				}
			}
			$myobj = json_decode('{'.$res.'}');
			}
		?>

		
		<!-- To ensure proper rendering and touch zooming -->
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<link rel="stylesheet" href="content/v/f2d0a96e2884/shared/css/base.css" type="text/css" />
		<link href="style.css" rel="stylesheet" type="text/css"/>
		<link href="bootstrap-3.3.5-dist/css/bootstrap.min.css" rel="stylesheet">
		<link href='http://fonts.googleapis.com/css?family=Dosis' rel='stylesheet' type='text/css'>
		<script src="https://code.jquery.com/jquery.js"></script>
        <script src="bootstrap-3.3.5-dist/js/bootstrap.min.js"></script>
		<script type="text/javascript" src="https://www.google.com/jsapi"></script>
		<script type="text/javascript">
			google.load("visualization", "1", {packages:['corechart','line','map']});
			google.setOnLoadCallback(lineChart);
			google.setOnLoadCallback(drawChart);
			google.setOnLoadCallback(drawChart2);
			google.setOnLoadCallback(drawMap1);
			google.setOnLoadCallback(drawMap2);
			
			function drawMap1() {
			var data = google.visualization.arrayToDataTable([
			  ['Lat', 'Long', 'Name', 'Marker'],
			  <?php echo $myobj->mapData; ?>
			]);

			var url = 'http://icons.iconarchive.com/icons/icons-land/vista-map-markers/48/';
			var options = {
			zoomLevel: 2,
			showTip: true,
			useMapTypeControl: true,
			showTip: true,
			icons: {
			  blue: {
				normal:   url + 'Map-Marker-Ball-Azure-icon.png',
				selected: url + 'Map-Marker-Ball-Right-Azure-icon.png'
			  },
			  green: {
				normal:   url + 'Map-Marker-Ball-Chartreuse-icon.png',
				selected: url + 'Map-Marker-Ball-Right-Chartreuse-icon.png'
			  },
			  red: {
				normal:   url + 'Map-Marker-Ball-Pink-icon.png',
				selected: url + 'Map-Marker-Ball-Right-Pink-icon.png'
			  }
			}
			};

			var map = new google.visualization.Map(document.getElementById('map'));
			map.draw(data,options);
			}

			function drawMap2() {
			var data = google.visualization.arrayToDataTable([
			  ['Lat', 'Long', 'Name', 'Marker'],
			  <?php echo $myobj->sourcesMapData; ?>
			]);

			var options = {
			zoomLevel: 2,
			showTip: true,
			useMapTypeControl: true,
			showTip: true,
			icons: {
			  windowsPhone: {
				normal:   'http://icons.iconarchive.com/icons/yootheme/social-bookmark/32/social-windows-button-icon.png',
				selected: 'http://icons.iconarchive.com/icons/yootheme/social-bookmark/32/social-windows-button-icon.png'
			  },
			  Twitter: {
				normal:   'http://icons.iconarchive.com/icons/danleech/simple/32/twitter-icon.png',
				selected: 'http://icons.iconarchive.com/icons/danleech/simple/32/twitter-icon.png'
			  },
			  Iphone: {
				normal:   'http://icons.iconarchive.com/icons/danleech/simple/32/apple-icon.png',
				selected: 'http://icons.iconarchive.com/icons/danleech/simple/32/apple-icon.png'
			  },
			  Android: {
				normal:   'http://icons.iconarchive.com/icons/danleech/simple/32/android-icon.png',
				selected: 'http://icons.iconarchive.com/icons/danleech/simple/32/android-icon.png'
			  },
			  blackBerry: {
				normal:   'http://icons.iconarchive.com/icons/hopstarter/rounded-square/32/Blackberry-icon.png',
				selected: 'http://icons.iconarchive.com/icons/hopstarter/rounded-square/32/Blackberry-icon.png'
			  },
			  Instagram: {
				normal:   'http://icons.iconarchive.com/icons/designbolts/free-instagram/32/Active-Instagram-1-icon.png',
				selected: 'http://icons.iconarchive.com/icons/designbolts/free-instagram/32/Active-Instagram-1-icon.png'
			  },
			  other: {
				normal:   'http://icons.iconarchive.com/icons/hopstarter/sleek-xp-basic/32/Help-icon.png',
				selected: 'http://icons.iconarchive.com/icons/hopstarter/sleek-xp-basic/32/Help-icon.png'
			  },
			}
			};

			var map = new google.visualization.Map(document.getElementById('map2'));
			map.draw(data,options);
			}

			function drawChart() {
				var data = google.visualization.arrayToDataTable([
				  ['Opinion', 'Score'],
				  ['Positive', <?php echo $myobj->Positive; ?>],
				  ['Negative', <?php echo $myobj->Negative; ?>],
				  ['Neutral', <?php echo $myobj->Neutral; ?>]
				]);

				var options = {
					pieSliceText: 'label',
					title: 'Sentiment Score',
					pieHole: 0.3,
				};

				var chart = new google.visualization.PieChart(document.getElementById('donutchart'));
				chart.draw(data, options);
			}

			function drawChart2() {
				var data = google.visualization.arrayToDataTable([
				  ['Source', 'Users'],
				  <?php echo $myobj->sourcePieChart; ?>
				]);

				var options = {
					pieSliceText: 'label',
					title: 'Top Sources',
					 pieStartAngle: 100,
				};

				var chart = new google.visualization.PieChart(document.getElementById('donutchart2'));
				chart.draw(data, options);
			}
			
			function lineChart() {
				var data = new google.visualization.DataTable();
				data.addColumn('number', 'Period');
				data.addColumn('number', 'AVG Score');

				data.addRows([
					<?php echo $myobj->lineChart; ?>
				]);

				var options = {
				chart: {
					title: 'Tweets Scores for <?php echo $N; ?>',
					subtitle: 'From: <?php echo $myobj->from;?> To: <?php echo $myobj->to;?>',
					backgroundColor: '#00cc00'				
				},
				};

				var chart = new google.charts.Line(document.getElementById('lineChart'));

				chart.draw(data, options);
			}			

			function showStat() {
				document.getElementById('my_form').submit();
				document.getElementById("stat").style.display = 'block';
			}
						
			function changeClassLink(id) {
				document.getElementById(id).className = "selectedLink";
				if (id == "realLink") {
					document.getElementById("histLink").className = "lightLink";
					document.getElementById("realform").style.display = 'block';					
					document.getElementById("histform").style.display = 'none';
				} else {
					document.getElementById("realLink").className = "lightLink";
					document.getElementById("realform").style.display = 'none';					
					document.getElementById("histform").style.display = 'block';
				}
			}

			$(document).on('click', '.browse', function(){
			  var file = $(this).parent().parent().parent().find('.file');
			  file.trigger('click');
			});

			$(document).on('change', '.file', function(){
			  $(this).parent().find('.form-control').val($(this).val().replace(/C:\\fakepath\\/i, ''));
			});			

			$(function () {
				  $('[data-toggle="popover"]').popover();
				  $('#help').data('bs.popover').options.content = "<strong>Real Time Tracking:</strong><br>What would you like to track in real-time? Enter a keyword or a hashtag to track in real-time (e.g. Iphone)<br><br><strong>Historical Data:</strong><br> Get real insights from historical data whether it's a campaign you ran last month, or an event that took place a year ago. Enter a keyword or a hashtag to track in real-time (e.g. Iphone)";	

			})

			$(document).ready(function () {
				$(window).scrollTop('540');
				return false;
			});    		
		</script>

	</head>
	<body>
		<div id="header2">
			<a href="home.php"><img style="margin-left: 4%;" alt="datapedia" src="logo.png" height="80" width="250"></a>
<a class="btn btn-info btn-md icon-white" href="aboutUs.html" style="float:right; margin-right: 4%; margin-top: 2%;color:#fff; background:#466c86; border:none; width:100px; height:35px;">About us<a>
		</div>

		<div class="full-front" >
			<div style="padding-top:1px; padding-bottom:150px; background-image:url('bg1.jpg'); height:460px;">
				<a style="text-decoration:none;"><h1>The Home of HashTags</h1></a>
				<div id="searchArea">
					<form id="my_form" class="form-inline" action='statistics.php' method='get'>
						<h2 style="font-size:160%;color:#466c86;padding-right:70px;">
							<a id="help" style="text-decoration:none;padding-right:10px;" data-toggle="popover" data-placement="left" data-trigger="hover" data-html="true">
								<span class="glyphicon glyphicon-info-sign"></span>
							</a>
							<a id="realLink" href="#" class="selectedLink" onclick="changeClassLink('realLink');" >RealTime Tracking<a/>
							<a id="histLink" href="#" class="lightLink" onclick="changeClassLink('histLink');" style="margin-left:40px;">Historical Analytics<a/>
						</h2>
						<div id="realform">
							<div class="input-group">
								<label class="sr-only">Text</label>
								<input name="N" id="hashtag" style="width:500px" type="text" class="form-control" placeholder="Enter a #hashtag, keyword" required>
								<input id="searchBtn" type="submit" class="btn btn-primary" style="color:#fff; background:#466c86; border:none; width:100px; height:35px;">
								</input>
							</div>
						</div>
						<div id="histform" style="display:none;">
							<div class="input-group">
								<input type="file" class="file">
								<label class="sr-only">Text</label>
								<input name="H" id="hashtag" name="H" style="width:500px" type="text" class="form-control" placeholder="Upload File" >
								<button class="browse btn btn-primary" style="color:#fff; background:#466c86;border:none;width:100px;height:35px;" type="button"><i class="glyphicon glyphicon-search"></i> Browse</button>
							</div>
							<br/><br/>
							<a id="submitBtn" class="btn btn-primary" onclick="showStat()" 
							style="color:#fff; background:#466c86;border:none;width:100px;">
								Submit
							</a>
						</div>
					</form>
				</div>
			</div>
		</div>
		
		
		<div id="stat">
			<hr />
			<div class="container-fluid" >
				<div style="margin-left:6%; margin-right:6%;">
					<div class="alert alert-danger" style="text-align:center; font-size:18px; display:block;">
					<p style="font-family: 'Dosis', sans-serif;font-size:1.3em;">This preview only contains sample data. If you continue, all future posts will be captured in real-time.</p>
					</div>
				</div>
				
				<div class="statBorder" style="font-family:'Dosis',sans-serif;">
					<div class="row">
						<div class="col-lg-2 col-lg-offset-1" style="text-align:center;">
							<span style="color:rgb(54, 131, 153); font-size: 46px !important;"><?php echo $myobj->Positive+$myobj->Negative+$myobj->Neutral; ?></span>
							<br>
							<span style="font-size: 18px; color: rgb(54, 131, 153);">Tweets</span>
						</div>
						<div class="col-lg-2" style="text-align:center;">
							<span style="color:rgb(54, 131, 153); font-size: 46px !important;"><?php echo $myobj->numOfUsers; ?></span>
							<br>
							<span style="font-size: 18px; color: rgb(54, 131, 153);">Users</span>
						</div>
						<div class="col-lg-2" style="text-align:center;">
							<span style="color:rgb(54, 131, 153); font-size: 46px !important;"><?php echo $myobj->Positive; ?></span>
							<br>
							<span style="font-size: 18px; color: rgb(54, 131, 153);">Positive</span>
						</div>
						<div class="col-lg-2" style="text-align:center;">
							<span style="color:rgb(54, 131, 153); font-size: 46px !important;"><?php echo $myobj->Negative; ?></span>
							<br>
							<span style="font-size: 18px; color: rgb(54, 131, 153);">Negative</span>
						</div>
						<div class="col-lg-2" style="text-align:center;">
							<span style="color:rgb(54, 131, 153); font-size: 46px !important;"><?php echo $myobj->Neutral; ?></span>
							<br>
							<span style="font-size: 18px; color: rgb(54, 131, 153);">Neutral</span>
						</div>
					</div>
					<br><br>
					<div class="row" style="margin-left:2%; " >
						<div class="title">
							Most Popular tweet :
						</div>
						<div class="well well-sm" style="margin-left:100px;margin-right:100px;">
							<span style="font-size:17px; font-family:'Dosis',sans-serif;"><?php echo $myobj->mostFavorited; ?></span>
						</div>
					</div>
					<br>
					<div class="row" style="margin-left:2%; ">
						<div class="title">
							Most Retweeted tweet :
						</div>
						<div class="well well-sm" style="margin-left:100px;margin-right:100px;">
							<span style="font-size:17px; font-family:'Dosis',sans-serif;"><?php echo $myobj->mostRetweeted; ?></span>
						</div>	
					</div>
					<br>
					<div class="row" style="margin-left:2%; ">
						<div class="title">
							 Top Mentioned Hashtags# :
						</div>
						<div class="well well-sm" style="margin-left:100px;margin-right:100px;">
							<span style="font-size:17px; font-family:'Dosis',sans-serif;"><?php echo $myobj->hash1; ?></span>
							,
							<span style="font-size:17px; font-family:'Dosis',sans-serif;"><?php echo $myobj->hash2; ?></span>
							,
							<span style="font-size:17px; font-family:'Dosis',sans-serif;"><?php echo $myobj->hash3; ?></span>
						</div>	
					</div>
					<br><br>
					<div class="row" style="margin-left:2%; ">
						<span style="font-size:14px; font-family:'Dosis',sans-serif;font-size:1.3em;">Sentiment Analysis</span>
					</div>					
					<div class="row">
						<div class="col-lg-6">
							<div id="donutchart" style="width:80%;height:50%;"></div>
						</div>
						<div class="col-lg-6">
							<div id="lineChart" style="width:80%;height:50%;"></div>
						</div>
					</div>
					<br><br>
					<div class="row">
						<div class="col-lg-11 col-lg-offset-1">
							<div id="map" style="width:90%;height:50%;"></div>
						</div>
					</div>
					<hr/>
					<div class="row" style="margin-left:2%; ">
						<span style="font-size:14px; font-family:'Dosis',sans-serif;font-size:1.3em;">Sources Analysis</span>
					</div>					
					<div class="row">
						<div class="col-lg-6">
							<div id="donutchart2" style="width:80%;height:50%;"></div>
						</div>
						<div class="col-lg-6">
							<div id="map2" style="width:80%;height:50%;"></div>
						</div>
					</div>
					<br><br>
				</div>
			</div>
		</div>
		<div id="footer" style="padding-top:10px;">
			<div id="footer-inside">
				<div id="footer-copyright">
						© 2015 Datapedia
				</div>
			</div>
		</div>
	</body>
</html>
