(function () {
    var widget = Retina.Widget.extend({
        about: {
                title: "Amplicon Pipeline Widget",
                name: "pipeline",
                author: "Tobias Paczian",
                requires: [ ]
        }
    });
    
    widget.setup = function () {
	return [ Retina.load_renderer("table") ];
    };
    
    /*
      GLOBAL VARIABLES
    */
    widget.jobDataOffset;

    widget.settingsMapping = [
	[ "assembled", "sequence file is assembled" ],
	[ "dereplicate", "remove artificial replicate sequences" ],
	[ "screen_indexes", "remove any host specific species sequences" ],
	[ "dynamic_trim", "remove low quality sequences" ],
	[ "min_qual", "lowest phred score to count as a high-quality base" ],
	[ "max_lqb", "trimmed to at most this many low phred score bases" ],
	[ "filter_ln", "filter based on sequence length" ],
	[ "deviation", "multiplicator of standard deviation for length cutoff" ],
	[ "filter_ambig", "Filter based on sequence ambiguity base count" ],
	[ "max_ambig", "maximum allowed number of ambiguous basepairs" ]
    ];
    
    widget.screeningMapping = {
	"h_sapiens": "H. sapiens, NCBI v36",
	"m_musculus": "M. musculus, NCBI v37",
	"b_taurus": "B. taurus, UMD v3.0",
	"d_melanogaster": "D. melanogaster, Flybase, r5.22",
	"a_thaliana": "A. thaliana, TAIR, TAIR9",
	"e_coli": "E. coli, NCBI, st. 536",
	"s_scrofa": "Sus scrofa, NCBI v10.2",
	"none": "none"
    };

    widget.priorityMapping = {
	"never": [ "lowest", "never" ],
	"date": [ "low", "eventually" ],
	"6months": [ "medium", "after 6 months" ],
	"3months": [ "high", "after 3 months" ],
	"immediately": [ "highest", "immediately" ]
    };
    
    /*
      DISPLAY
     */
    widget.display = function (wparams) {
       var  widget = Retina.WidgetInstances.pipeline[1];

	if (! stm.DataStore.hasOwnProperty('metagenome')) {
	    stm.DataStore.metagenome = {};
	}
	
	if (wparams && wparams.main) {
	    widget.main = wparams.main;
	    widget.sidebar = wparams.sidebar;
	}
	var content = widget.main;
	var sidebar = widget.sidebar;
	
	// set the output area
	sidebar.parentNode.className = "span5 sidebar";
	document.getElementById('sidebarResizer').style.display = "none";
	content.className = "span5 offset1";

	// check for parameterization
	if (Retina.cgiParam('user')) {
	    widget.userID = Retina.cgiParam('user');
	}

	// check if we have a user
	if (stm.user) {
	    sidebar.innerHTML = "<h3 style='margin-left: 10px;'>Job Status Monitor</h3><p style='margin-left: 10px;'>Click on a job id in the lefthand table to get details on the status of that submission.</p>";
	    
	    if (! widget.userID) {
		content.innerHTML = "<img src='Retina/images/waiting.gif' style='margin-left: 45%; margin-top: 300px;'>";
		widget.userID = stm.user.login;
	    }
	    // title
	    var html = "<div class='btn-group' data-toggle='buttons-checkbox' style='margin-bottom: 20px;'><a href='?mgpage=upload' class='btn btn-large' style='width: 175px;'><img style='height: 16px; margin-right: 5px; position: relative;' src='Retina/images/cloud-upload.png'>upload data</a><a href='?mgpage=submission' class='btn btn-large' style='width: 175px;'><img style='height: 16px; margin-right: 5px; position: relative;' src='Retina/images/settings.png'>perform submission</a><a href='?mgpage=pipeline' class='btn btn-large active' style='width: 175px;'><img style='height: 16px; margin-right: 5px; position: relative;' src='Retina/images/settings3.png'>job status</a></div>";

	    // new title
	    html = '<div class="wizard span12">\
	  <div>\
	    <li></li>\
	    <a href="?page=upload">upload<img src="Retina/images/cloud-upload.png"></a>\
	  </div>\
	  <div class="separator">›</div>\
	  <div>\
	    <li></li>\
	    <a href="?page=submission">submit<img src="images/forward.png"></a>\
	  </div>\
	  <div class="separator">›</div>\
	  <div>\
	    <li class="active"></li>\
	    <a href="#" class="active">progress<img src="Retina/images/settings3.png"></a>\
	  </div>\
	</div><div style="clear: both; height: 20px;"></div>';
	    
	    // show running jobs
	    html += "<p>The submission process is complete and you can now safely close your browser. You can come back to this page or reload it at any time to monitor the progress of your submission.</p><p>The table below shows the status of your submissions as they progress through our pipeline. Click on the job number in the first column to view details of that specific job. The status lights in the last column show an overview of which tasks have been completed and which still need to run.</p>";
	    html += "<div id='jobtable'></div>";

	    content.innerHTML = html;

	    // load submissions in progress
	    jQuery.ajax(RetinaConfig['mgrast_api']+"/submission/list", {
		success: function(data){
		    var showSubs = [];
		    for (var i=0; i<data.submissions.length; i++) {
			var s = data.submissions[i];
			if (s.status !== 'deleted' && s.status !== 'completed') {
			    showSubs.push(s);
			}
		    }
		    Retina.WidgetInstances.pipeline[1].submissionData = showSubs;
		    Retina.WidgetInstances.pipeline[1].job_table.update({},1);
		},
		error: function(jqXHR, error){
		},
		crossDomain: true,
		headers: stm.authHeader,
		type: "GET"
	    });

	    // create the job table
	    var job_columns = [ "job", "mgid", "stage", "status", "tasks" ];

	    var job_table_filter = { 0: { "type": "text" },
				     3: { "type": "text" } };
	    if (! widget.hasOwnProperty('job_table')) {
		widget.job_table = Retina.Renderer.create("table", {
		    target: document.getElementById('jobtable'),
		    rows_per_page: 20,
		    invisible_columns: { 1: true },
		    filter_autodetect: false,
		    filter: job_table_filter,
		    sort_autodetect: true,
		    synchronous: false,
		    sort: "updatetime",
		    query_type: "equal",
		    default_sort: "job",
		    asynch_column_mapping: { "job": "info.name",
					     "mgid": "info.userattr.id",
					     "status": "state" },
		    headers: stm.authHeader,
		    data_manipulation: Retina.WidgetInstances.pipeline[1].jobTable,
		    minwidths: [1,1,1,1],
		    navigation_url: RetinaConfig['mgrast_api'] + "/pipeline?info.pipeline=mgrast-prod&info.user="+widget.userID,
		    data: { data: [], header: job_columns }
		});
	    } else {
		widget.job_table.settings.target = document.getElementById('jobtable');
	    }
	    widget.job_table.render();
	    widget.job_table.update({},1);

	    if (Retina.cgiParam('admin')) {
		var title = document.createElement('div');
		title.innerHTML = "<h4 style='margin-top: 25px;'>change user (currently: "+widget.userID+")</h4>";
		content.appendChild(title);
		var utable = document.createElement('div');
		utable.setAttribute('id', 'usertable');
		content.appendChild(utable);

		// create the user table
		if (! widget.hasOwnProperty('user_table')) {
		    widget.user_table = Retina.Renderer.create("table", {
			target: document.getElementById('usertable'),
			rows_per_page: 5,
			filter_autodetect: false,
			filter: { 0: { "type": "text" },
				  1: { "type": "text" },
				  2: { "type": "text" },
				  3: { "type": "text" },
				  4: { "type": "text" } },
			invisible_columns: { 3: true },
			sort_autodetect: true,
			synchronous: false,
			sort: "lastname",
			default_sort: "lastname",
			headers: stm.authHeader,
			data_manipulation: Retina.WidgetInstances.pipeline[1].userTable,
			navigation_url: RetinaConfig.mgrast_api+'/user?verbosity=minimal',
			data: { data: [], header: [ "login", "firstname", "lastname", "email", "id" ] }
		    });
		} else {
		    widget.user_table.settings.target = document.getElementById('usertable');
		}
		widget.user_table.render();
		widget.user_table.update({},2);
	    }
	    if (Retina.cgiParam('job')) {
		jQuery.ajax({
		    method: "GET",
		    dataType: "json",
		    headers: stm.authHeader,
		    url: RetinaConfig.mgrast_api+'/pipeline/'+Retina.cgiParam('job'),
		    success: function (data) {
			if (! stm.DataStore.hasOwnProperty('job')) {
			    stm.DataStore.job = {};
			}
			stm.DataStore.job[data.data[0].id] = data.data[0];
			Retina.WidgetInstances.pipeline[1].showJobDetails(data.data[0].id);
		    }});
	    }
	}
	// there is no user, show login required
	else {
	    content.innerHTML = '<h3>Login required</h3><p>You need to log in at the top right of the screen to view this page.</p><p>If you do not yet have an account, you can <button class="btn" style="margin-top: -5px;">register here</button></p>';
	}
    };

    /*
      MAIN CONTENT
     */
    widget.jobTable = function (data) {
	var widget = Retina.WidgetInstances.pipeline[1];

	// store the data in the DataStore
	if (! stm.DataStore.hasOwnProperty('job')) {
	    stm.DataStore.job = {};
	}
	for (var i=0; i<data.length; i++) {
	    stm.DataStore.job[data[i].id] = data[i];
	}

	var result_data = [];

	// check if there is submission data and prepend it
	if (widget.submissionData) {
	    for (var i=0; i<widget.submissionData.length; i++) {
		var d = widget.submissionData[i];
		var action = "";
		if (d.status == "suspend" || d.status == "error") {
		    d.status = "error";
		    action = " <button class='btn btn-mini' onclick='alert(\"Please report this error to mg-rast@rt.mcs.anl.gov and paste the submission id: "+d.id+"\");'>?</button>";
		}
		result_data.push({ "job": "<a href='#'>-</a>",
				   "mgid": d.id,
				   "stage": "submission",
				   "status": widget.status(d.status) + action,
				   "tasks": widget.dots([{"state": d.status, "cmd": { "description": "submission" } }])
				 });
	    }
	}

	// iterate over data rows
	for (var i=0; i<data.length; i++) {
	    if (data[i].state == "deleted") {
		result_data.push({ "job": data[i].info.name,
				   "mgid": data[i].info.userattr.id,
				   "stage": "-",
				   "status": "deleted",
				   "tasks": "-"
				 });
	    } else {
		result_data.push({ "job": "<a href='#' onclick='Retina.WidgetInstances.pipeline[1].showJobDetails(\""+data[i].id+"\");'>"+data[i].info.name+"</a>",
				   "mgid": data[i].info.userattr.id,
				   "stage": data[i].remaintasks > 0 ? data[i].tasks[data[i].tasks.length - data[i].remaintasks].cmd.description : "complete",
				   "status": widget.status(data[i].state),
				   "tasks": widget.dots(data[i].tasks)
				 });
	    }
	}

	return result_data;
    };

    widget.userTable = function (data) {
	var widget = Retina.WidgetInstances.pipeline[1];

	for (var i=0; i<data.length; i++) {
	    data[i].login = "<a href='#' onclick='Retina.WidgetInstances.pipeline[1].changeDisplayUser(\""+data[i].login+"\");'>"+data[i].login+"</a>";
	}

	return data;
    };

    widget.changeDisplayUser = function (id) {
	var widget = this;
	
	widget.userID = id;
	widget.job_table.settings.navigation_url = RetinaConfig['mgrast_api'] + "/pipeline?info.pipeline=mgrast-prod&info.user="+widget.userID;
	widget.display();
    };
    
    /*
      SIDEBAR CONTENT
     */
    widget.showJobDetails = function (id) {
	var widget = this;

	widget.sidebar.innerHTML = "<img src='Retina/images/waiting.gif' style='margin-left: 40%; margin-top: 50px; margin-bottom: 50px;'>";
	
	// get the job data from the DataStore
	var job = stm.DataStore.job[id];
	var jobid = id;

	// get the metagenome data if available
	var metagenome;
	if (stm.DataStore.metagenome.hasOwnProperty(job.info.userattr.id)) {
	    metagenome = stm.DataStore.metagenome[job.info.userattr.id];
	} else {
	    jQuery.ajax({
		method: "GET",
		dataType: "json",
		headers: stm.authHeader, 
		url: RetinaConfig.mgrast_api+'/metagenome/'+job.info.userattr.id,
		success: function (data) {
		    stm.DataStore.metagenome[data.id] = data;
		    Retina.WidgetInstances.pipeline[1].showJobDetails(jobid);
		}}).fail(function(xhr, error) {
		    Retina.WidgetInstances.pipeline[1].sidebar.innerHTML = "<div class='alert alert-error' style='margin: 20px;'>could not retrieve detail data</div>";
		});
	    return;
	}

	// create the html
	var html = '\
<h3 style="margin-left: 10px;">'+job.info.userattr.name+' ('+job.info.name+')</h3>\
<ul class="nav nav-tabs" style="position: relative; left: -1px;">\
  <li class="active">\
    <a href="#status" data-toggle="tab">Status</a>\
  </li>\
  <li>\
    <a href="#stage" data-toggle="tab" id="pheader">Pipeline</a>\
  </li>\
  <li>\
    <a href="#settings" data-toggle="tab" id="sheader">Settings</a>\
  </li>\
</ul>\
<div class="tab-content">\
  <div id="status" class="tab-pane fade active in">'+widget.statusDetails(job)+'</div>\
  <div id="stage" class="tab-pane fade">'+widget.stagePills(job)+'</div>\
  <div id="settings" class="tab-pane fade">'+widget.jobSettings(job)+'</div>\
</div>';

	widget.sidebar.innerHTML = html;
    };
    
    widget.jobSettings = function (job) {
	var widget = this;

	var html = "<p>Below are the pipeline options and the choice on when the completed data will be made publicly available chosen at submission time.</p><h4>pipeline options</h4>";

	if (stm.DataStore.metagenome.hasOwnProperty(job.info.userattr.id)) {
	    html += "<table class='table table-condensed'>";
	    var settings = stm.DataStore.metagenome[job.info.userattr.id].pipeline_parameters;
	    var dyn = false;
	    var len = false;
	    var amb = false;
	    for (var i=0; i<widget.settingsMapping.length; i++) {
		if (settings.hasOwnProperty(widget.settingsMapping[i][0])) {
		    var val = settings[widget.settingsMapping[i][0]];
		    if (widget.settingsMapping[i][0] == "screen_indexes") {
			val = widget.screeningMapping[val];
		    } else if (widget.settingsMapping[i][0] == "dynamic_trim") {
			if (val == "yes") {
			    dyn = true;
			}
		    } else if (widget.settingsMapping[i][0] == "filter_ln") {
			if (val == "yes") {
			    len = true;
			}
		    } else if (widget.settingsMapping[i][0] == "filter_ambig") {
			if (val == "yes") {
			    amb = true;
			}
		    } else if (((widget.settingsMapping[i][0] == "max_lqb") || (widget.settingsMapping[i][0] == "min_qual")) && ! dyn) {
			continue;
		    } else if ((widget.settingsMapping[i][0] == "deviation") && ! len) {
			continue;
		    } else if ((widget.settingsMapping[i][0] == "max_ambig") && ! amb) {
			continue;
		    }
		    html += "<tr><td><b>"+widget.settingsMapping[i][1]+"</b></td><td>"+val+"</td></tr>";
		}
	    }
	    html += "</table>";
	    
	    var jobpriority = "lowest";
	    var prio = "never";
	    if (stm.DataStore.metagenome.hasOwnProperty(job.info.userattr.id)) {
		prio = stm.DataStore.metagenome[job.info.userattr.id].pipeline_parameters.priority;
		jobpriority = widget.priorityMapping[prio][0];
		prio = widget.priorityMapping[prio][1];
	    }
	    html += "<h4>priority setting</h4><p>Your choice on when to make your data publicly available was</p>";
	    html += "<div class='alert alert-info' style='width: 100px; text-align: center; margin-left: auto; margin-right: auto; padding: 8px 14px 8px 14px;'>"+prio+"</div><p>This causes the priority of your job in the pipeline to be</p><div class='alert alert-info' style='width: 100px; text-align: center; margin-left: auto; margin-right: auto; padding: 8px 14px 8px 14px;'>"+jobpriority+"</div>";
	}

	return html;
    };

    widget.statusDetails = function (job) {
	var widget = this;

	var average_wait_time = widget.averageWaitTime(job.info.priority, job.tasks[0].inputs[Retina.keys(job.tasks[0].inputs)[0]].size);	
	var html = "";

	if (RetinaConfig.v3) {
	    html += "<p>The job <b>"+job.info.userattr.name+" ("+job.info.name+")</b> was submitted as part of the project <b><a href='"+RetinaConfig.v3CGIUrl+"?page=MetagenomeProject&project="+job.info.userattr.project_id.replace(/mgp/, "")+"' target=_blank>"+job.info.project+"</a></b> at <b>"+widget.prettyAWEdate(job.info.submittime)+"</b>.</p>";
	} else {
	    html += "<p>The job <b>"+job.info.userattr.name+" ("+job.info.name+")</b> was submitted as part of the project <b><a href='?mgpage=project&project="+job.info.userattr.project_id+"' target=_blank>"+job.info.project+"</a></b> at <b>"+widget.prettyAWEdate(job.info.submittime)+"</b>.</p>";
	}

	html += "<p>The current status is <b>"+job.state+"</b>, ";
	if (job.state == "suspend") {
	    if (Retina.cgiParam('admin')) {
		html += "the error message is:</p>";
		html += "<pre>"+job.notes+"</pre>";
	    } else {
		html += widget.errorHandling(job);
	    }
	} else {
	    if (job.remaintasks > 0) {
		if (job.remaintasks < 25) {
		    html += job.remaintasks + " out of " + job.tasks.length + " tasks still need to run before it is complete. You can look at the details of the completed tasks in the <a href='#' onclick='document.getElementById(\"pheader\").click();'>Pipeline</a> tab.";
		} else {
		    html += "no task has started computation yet.";
		}
	    } else {

		// time from submission to completion
		var time_passed = widget.timePassed(Date.parse(job.info.submittime), Date.parse(job.info.completedtime));
		html += "the computation is finished. It took <b>"+time_passed+"</b> from job submission until completion.";

		if (RetinaConfig.v3) {
		    html += "<p>The result data is available for download on the <a href='"+RetinaConfig.v3CGIUrl+"?page=DownloadMetagenome&metagenome="+job.info.userattr.id.replace(/mgm/, "")+"' target=_blank>download page</a>. You can take a look at the overview analysis data on the <a href='"+RetinaConfig.v3CGIUrl+"?page=MetagenomeOverview&metagenome="+job.info.userattr.id.replace(/mgm/, "")+"' target=_blank>metagenome overview page</a>.</p>";
		} else {
		    html += "<p>The result data is available for download on the <a href='?mgpage=download&metagenome="+Retina.idmap(job.info.userattr.id)+"' target=_blank>download page</a>. You can take a look at the overview analysis data on the <a href='?mgpage=overview&metagenome="+Retina.idmap(job.info.userattr.id)+"' target=_blank>metagenome overview page</a>.</p>";
		}
	    }
	    html += "</p>";
	    
	    if (job.remaintasks > 0) {
		// time since submission
		var time_passed = widget.timePassed(Date.parse(job.info.submittime), new Date().getTime());
		var jsize = 0;
		for (var i in job.tasks[0].inputs) {
		    if (job.tasks[0].inputs.hasOwnProperty(i)) {
			jsize = job.tasks[0].inputs[i].size.byteSize();
			break;
		    }
		}

		var jobpriority = "lowest";
		if (stm.DataStore.metagenome.hasOwnProperty(job.info.userattr.id)) {
		    jobpriority = widget.priorityMapping[stm.DataStore.metagenome[job.info.userattr.id].pipeline_parameters.priority][0];
		}
		
		html += "<p>The job has been in the pipeline for <b>"+time_passed+"</b>. The input file of this job has a size of <b>"+jsize+"</b> and is running with <b>"+jobpriority+"</b> priority. The average wait time for these parameters is currently <b>"+average_wait_time+"</b>.</p>";
		
		html += "<p>If you want to stop the computation of this job  and remove it from the system you can delete it using the button below.</p>";
		html += "<p style='text-align: center;'><button class='btn btn-danger btn-small' id='deleteButton' onclick='Retina.WidgetInstances.pipeline[1].deleteJob(\""+job.info.userattr.id+"\");'>delete</button></p>";
	    }
	}

	if (job.remaintasks > 0 && Retina.cgiParam('admin')) {
	    html += "<h4>Administrator Tasks</h4><div>";
	    html += "<div style='margin-bottom: 10px;'>This job is owned by user <a href='#' onclick='Retina.WidgetInstances.pipeline[1].changeDisplayUser(\""+job.info.user+"\");'>"+job.info.user+"</a></div>";
	    html += "<div class='input-append' style='margin-bottom: 0px; margin-right: 20px;'><input type='text' id='jobPriorityField' value='"+job.info.priority+"' style='margin-bottom: 0px; width: 100px;'><button class='btn' style='width: 100px;' onclick='Retina.WidgetInstances.pipeline[1].adminAction(\"priority\", \""+job.id+"\");'>set priority</button></div>";
	    html += "<button class='btn btn-primary' style='margin-right: 20px; width: 100px;' onclick='Retina.WidgetInstances.pipeline[1].adminAction(\"resume\", \""+job.id+"\");'>resume</button>";
	    html += "<button class='btn btn-warning' style='margin-right: 20px; width: 100px;' onclick='Retina.WidgetInstances.pipeline[1].adminAction(\"suspend\", \""+job.id+"\");'>suspend</button>";
	    html += "<button class='btn btn-danger' style='width: 100px;' onclick='Retina.WidgetInstances.pipeline[1].adminAction(\"delete\", \""+job.id+"\");'>delete</button>";
	    html += "</div>";
	}

	return html;
    };

    widget.errorHandling = function (job) {
	var widget = this;

	var html = "please <a href='contact.html?sbj="+encodeURIComponent("suspended job failed automatic resolution "+Retina.idmap(job.info.userattr.id))+"' target=_blank>contact our support team</a>.";

	// check if the failure was recent
	if (Date.now() - Date.parse(job.updatetime) < (48 * 60 * 60 * 1000)) {
	    html = "but the error occurred less than 48 hours ago. We check the queue daily and handle suspended jobs. If the job is still suspended after 48 hours, please send us a mail.";
	}

	// SHOCK server was unavailable
	if (job.notes.match(/lookup shock\.metagenomics.anl\.gov\: no such host/)) {
	    html = "but the error was likely transient. You can try to <a href='#' onclick='Retina.WidgetInstances.pipeline[1].adminAction(\"resume\", \""+job.id+"\");'>resume</a> it. If resuming fails, please <a href='contact.html?sbj="+encodeURIComponent("suspended job failed automatic resolution "+Retina.idmap(job.info.userattr.id))+"' target=_blank>contact our support team</a>.";
	}

	return html;
    };

    widget.stagePills = function (job) {
	var widget = this;

	var html = "<h4>this job has no tasks</h4>";
	if (job.tasks.length > 0) {
	    html = "<p>Below are all tasks that are part of the MG-RAST pipeline for your submission.</p><ul><li><span style='color: green;'>Green bars</span>, indicating completed tasks, can be expanded via mouseclick</li><li><span style='color: blue;'>Blue bars</span> indicate tasks currently being computed on</li><li><span style='color: orange;'>Orange bars</span> represent the next tasks to be queued</li><li><span style='color: gray;'>Gray tasks</span> are waiting for completion of another task they depend on</li><li><span style='color: red;'>Red bars</span> indicate an error</li></ul>";
	    for (var i=0; i<job.tasks.length; i++) {
		if (job.tasks[i].state == 'completed') {
		    html += '\
<div class="pill donepill clickable" onclick="if(document.getElementById(\'stageDetails'+i+'\').style.display==\'none\'){document.getElementById(\'stageDetails'+i+'\').style.display=\'\';}else{document.getElementById(\'stageDetails'+i+'\').style.display=\'none\';};">\
  <img class="miniicon" src="Retina/images/ok.png">\
  '+job.tasks[i].cmd.description+'\
  <span style="float: right;">'+widget.prettyAWEdate(job.tasks[i].completeddate)+'</span>\
</div><div style="display: none;" id="stageDetails'+i+'">'+widget.stageDetails(job.id, i)+'</div>';
		} else if (job.tasks[i].state == 'in-progress') {
		    html += '\
<div class="pill runningpill">\
  <img class="miniicon" src="Retina/images/settings3.png">\
  '+job.tasks[i].cmd.description+'\
  <span style="float: right;">'+widget.prettyAWEdate(job.tasks[i].starteddate)+'</span>\
</div>';
		} else if (job.tasks[i].state == 'queued') {
		    html += '\
<div class="pill queuedpill">\
  <img class="miniicon" src="Retina/images/clock.png">\
  '+job.tasks[i].cmd.description+'\
  <span style="float: right;">(in queue)</span>\
</div>';
		} else if (job.tasks[i].state == 'error') {
		    if (Retina.cgiParam('admin')) {
			html += '\
<div class="pill errorpill clickable" onclick="if(document.getElementById(\'stageDetails'+i+'\').style.display==\'none\'){document.getElementById(\'stageDetails'+i+'\').style.display=\'\';}else{document.getElementById(\'stageDetails'+i+'\').style.display=\'none\';};">\
  <img class="miniicon" src="Retina/images/remove.png">\
  '+job.tasks[i].cmd.description+'\
  <span style="float: right;">'+widget.prettyAWEdate(job.tasks[i].createddate)+'</span>\
</div><div style="display: none;" id="stageDetails'+i+'">'+widget.stageDetails(job.id, i)+'</div>';
		    } else {
			html += '\
<div class="pill errorpill">\
  <img class="miniicon" src="Retina/images/remove.png">\
  '+job.tasks[i].cmd.description+'\
  <span style="float: right;">'+widget.prettyAWEdate(job.tasks[i].createddate)+'</span>\
</div>';
		    }
		} else if (job.tasks[i].state == 'pending') {
		    html += '\
<div class="pill pendingpill">\
  <img class="miniicon" src="Retina/images/clock.png">\
  '+job.tasks[i].cmd.description+'\
  <span style="float: right;">(not started)</span>\
</div>';
		} else if (job.tasks[i].state == 'suspend') {
		    if (Retina.cgiParam('admin')) {
			html += '\
<div class="pill errorpill clickable" onclick="if(document.getElementById(\'stageDetails'+i+'\').style.display==\'none\'){document.getElementById(\'stageDetails'+i+'\').style.display=\'\';}else{document.getElementById(\'stageDetails'+i+'\').style.display=\'none\';};">\
  <img class="miniicon" src="Retina/images/remove.png">\
  '+job.tasks[i].cmd.description+'\
  <span style="float: right;">'+widget.prettyAWEdate(job.tasks[i].createddate)+'</span>\
</div><div style="display: none;" id="stageDetails'+i+'">'+widget.stageDetails(job.id, i)+'</div>';
		    } else {
			html += '\
<div class="pill errorpill">\
  <img class="miniicon" src="Retina/images/remove.png">\
  '+job.tasks[i].cmd.description+'\
  <span style="float: right;">'+widget.prettyAWEdate(job.tasks[i].createddate)+'</span>\
</div>';
		    }
		} else {
		    console.log('unhandled state: '+job.tasks[i].state);
		}
	    }
	}

	return html;
    };

    widget.downloadHead = function (nodeid, fn) {
	var widget = this;
	jQuery.ajax({
	    method: "GET",
	    fn: fn,
	    headers: stm.authHeader,
	    url: RetinaConfig.shock_url+'/node/'+nodeid + "?download&index=size&part=1&chunksize=10240",
	    success: function (data) {
		stm.saveAs(data, this.fn);
	    }}).fail(function(xhr, error) {
		alert("could not get head of file");
		console.log(error);
	    });
    };

    widget.stageDetails = function (jid, stage) {
	var widget = this;

	var task = stm.DataStore.job[jid].tasks[stage];

	var inputs = [];
	for (var i in task.inputs) {
	    if (task.inputs.hasOwnProperty(i)) {
		if (task.inputs[i].nofile || task.inputs[i].filename == "mysql.tar" || task.inputs[i].filename == "postgresql.tar") {
		    continue;
		}
		inputs.push(task.inputs[i].filename+" ("+task.inputs[i].size.byteSize()+")" + (Retina.cgiParam('admin') ? " <button class='btn btn-mini' onclick='Retina.WidgetInstances.pipeline[1].downloadHead(\""+task.inputs[i].node+"\", \""+i+"\");'>head 1MB</button>": ""));
	    }
	}
	inputs = inputs.join('<br>');
	var outputs = [];
	for (var i in task.outputs) {
	    if (task.outputs.hasOwnProperty(i)) {
		if (task.outputs[i].type == "update") {
		    continue;
		}
		outputs.push(task.outputs[i].filename+" ("+task.outputs[i].size.byteSize()+")"+(task.outputs[i]["delete"] ? " <i>temporary</i>" : "") + (Retina.cgiParam('admin') ? " <button class='btn btn-mini' onclick='Retina.WidgetInstances.pipeline[1].downloadHead(\""+task.outputs[i].node+"\", \""+i+"\");'>head 1MB</button>": ""));
	    }
	}
	outputs = outputs.join('<br>');

	var html = "<table class='table table-condensed'>";
	html += "<tr><td><b>started</b></td><td>"+widget.prettyAWEdate(task.createddate)+"</td></tr>";
	html += "<tr><td><b>completed</b></td><td>"+widget.prettyAWEdate(task.completeddate)+"</td></tr>";
	html += "<tr><td><b>duration</b></td><td>"+widget.timePassed(Date.parse(task.createddate), Date.parse(task.completeddate))+"</td></tr>";
	html += "<tr><td><b>inputs</b></td><td>"+inputs+"</td></tr>";
	html += "<tr><td><b>outputs</b></td><td>"+outputs+"</td></tr>";
	html += "</table>";
	
	return html;
    };

    /*
      ACTIONS
     */
    widget.deleteJob = function (mgid) {
	var widget = this;

	if (prompt("Really delete job "+mgid+"? This cannot be undone. Type 'DELETE' to confirm", "") == "DELETE") {
	    var reason = prompt("Why do you want to delete the job?", "- not specified -");
	    var form = new FormData();
	    form.append('metagenome_id', mgid);
	    form.append('reason', reason);
	    jQuery('#deleteButton').prop("disabled",true);
	    jQuery.ajax({
		method: "POST",
		dataType: "json",
		data: form,
		processData: false,
		contentType: false,
		headers: stm.authHeader, 
		url: RetinaConfig.mgrast_api+'/job/delete',
		success: function (data) {
		    alert("job deleted");
		    Retina.WidgetInstances.pipeline[1].display();
		}}).fail(function(xhr, error) {
		    alert("job deletion failed");
		    jQuery('#deleteButton').prop("disabled",false);
		    console.log(error);
		});
	}
    };

    widget.adminAction = function (action, id) {
	var widget = this;
	var job = stm.DataStore.job[id];
	
	var url = "?action="+action;
	if (action == 'delete') {
	    widget.deleteJob(job.info.userattr.id);
	    return;
	} else if (action == "priority") {
	    url += "&level=" + document.getElementById('jobPriorityField').value;
	}

	jQuery.ajax({
	    method: "GET",
	    dataType: "json",
	    headers: stm.authHeader, 
	    url: RetinaConfig.mgrast_api+'/pipeline/'+job.info.userattr.id+url,
	    success: function (data) {
		alert("action successful");
		Retina.WidgetInstances.pipeline[1].display();
	    }}).fail(function(xhr, error) {
		alert('action failed');
		console.log(error);
	    });
    };

    /*
      HELPER FUNCTIONS
     */
    widget.prettyAWEdate = function (date) {
	if (date == "0001-01-01T00:00:00Z") {
	    return "-";
	}
	var pdate = new Date(Date.parse(date)).toLocaleString();
	return pdate;
    };

    widget.dots = function (stages) {
	var dots = '<span>';
	if (stages.length > 0) {
	    for (var i=0;i<stages.length;i++) {
		if (stages[i] == null) {
		    continue;
		}
		if (stages[i].state == 'completed') {
		    dots += '<span style="color: green;font-size: 19px; cursor: default;" title="completed: '+stages[i].cmd.description+'">&#9679;</span>';
		} else if (stages[i].state == 'in-progress') {
		    dots += '<span style="color: blue;font-size: 19px; cursor: default;" title="in-progress: '+stages[i].cmd.description+'">&#9679;</span>';
		} else if (stages[i].state == 'queued') {
		    dots += '<span style="color: orange;font-size: 19px; cursor: default;" title="queued: '+stages[i].cmd.description+'">&#9679;</span>';
		} else if (stages[i].state == 'error') {
		    dots += '<span style="color: red;font-size: 19px; cursor: default;" title="error: '+stages[i].cmd.description+'">&#9679;</span>';
		} else if (stages[i].state == 'pending' || stages[i].state == 'init') {
		    dots += '<span style="color: gray;font-size: 19px; cursor: default;" title="pending: '+stages[i].cmd.description+'">&#9679;</span>';
		} else if (stages[i].state == 'suspend') {
		    dots += '<span style="color: red;font-size: 19px; cursor: default;" title="suspended: '+stages[i].cmd.description+'">&#9679;</span>';
		} else {
		    console.log("unhandled state: "+stages[i].state);
		}
	    }
	}
	
	dots += "</span>";
	
	return dots;
    };

    widget.status = function (state) {
	if (state == "completed") {
	    return '<img class="miniicon" src="Retina/images/ok.png"><span class="green">completed</span>';
	} else if (state == "in-progress") {
	    return '<img class="miniicon" src="Retina/images/settings3.png"><span class="blue">in-progress</span>';
	} else if (state == "queued") {
	    return '<img class="miniicon" src="Retina/images/clock.png"><span class="orange">queued</span>';
	} else if (state == "pending") {
	    return '<img class="miniicon" src="Retina/images/clock.png"><span class="gray">pending</span>';
	} else if (state == "error") {
	    return '<img class="miniicon" src="Retina/images/remove.png"><span class="red">error</span>';
	} else if (state == "suspend") {
	    return '<img class="miniicon" src="Retina/images/remove.png"><span class="red">suspend</span>';
	} else {
	    console.log("unhandled state: "+state);
	    return "";
	}
    };

    widget.averageWaitTime = function (prio, size) {
	var widget = this;

	var gb_per_day = 30;
	var gb_queued_better_prio_or_date = 300;
	var wait = (gb_queued_better_prio_or_date + (size / 1000000000)) / gb_per_day;
	
	return ((wait < 1) ? wait.formatString(1) : parseInt(wait))+ " days";
    };

    widget.timePassed = function (start, end) {
	// time since submission
	var time_passed = end - start;
	var day = parseInt(time_passed / (1000 * 60 * 60 * 24));
	time_passed = time_passed - (day * 1000 * 60 * 60 * 24);
	var hour = parseInt(time_passed / (1000 * 60 * 60));
	time_passed = time_passed - (hour * 1000 * 60 * 60);
	var minute = parseInt(time_passed / (1000 * 60));
	var some_time = ((day > 0) ? day+" days " : "") + ((hour > 0) ? hour+" hours " : "") + minute+" minutes";
	return some_time;
    };
})();
