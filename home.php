<html>
	<head>
		<title>Datapedia</title>
		
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<link rel="stylesheet" href="content/v/f2d0a96e2884/shared/css/base.css" type="text/css" />
		<link href="style.css" rel="stylesheet" type="text/css"/>
		<link href="bootstrap-3.3.5-dist/css/bootstrap.min.css" rel="stylesheet">
		<script src="https://code.jquery.com/jquery.js"></script>
        <script src="bootstrap-3.3.5-dist/js/bootstrap.min.js"></script>
		<script type="text/javascript" src="https://www.google.com/jsapi"></script>
		<script type="text/javascript">

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
			
		</script>

	</head>
	<body >
		<div id="header2">
			<a href="home.php"><img style="margin-left: 4%;" alt="datapedia" src="logo.png" height="80" width="250"></a>
			<a class="btn btn-info btn-md icon-white" href="aboutUs.html" style="float:right; margin-right: 4%; margin-top: 2%;color:#fff; background:#466c86; border:none; width:100px; height:35px;">About us<a>
		</div>

		<div class="full-front" >
			<div style="padding-top:1px;padding-bottom:150px;background-image:url('bg1.jpg');height:460px;">
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
</form>
<form id="my_form2" class="form-inline" action='statistics.php' method='get'>
						<div id="histform" style="display:none;">
							<div class="input-group">
								<input type="file" class="file">
								<label class="sr-only">Text</label>
								<input name="H" id="hashtag" style="width:500px" type="text" class="form-control" placeholder="Upload File" >
								<button class="browse btn btn-primary" style="color:#fff; background:#466c86;border:none;width:100px;height:35px;" type="button"><i class="glyphicon glyphicon-search"></i> Browse</button>
							</div>
							<br/><br/>
							<input id="submitBtn" class="btn btn-primary" type="submit" style="color:#fff; background:#466c86;border:none;width:100px;">
							</input>
						</div>
					</form>
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
