(function () {
    var widget = Retina.Widget.extend({
        about: {
                title: "Amplicon Upload Widget",
                name: "upload",
                author: "Tobias Paczian",
                requires: [ ]
        }
    });
    
    widget.inboxData = [];

    widget.setup = function () {
	return [ Retina.load_widget({ name: "shockbrowse", resource: "Retina/widgets" }) ];
    };
    
    widget.display = function (params) {
        var widget = this;
	var index = widget.index;
	
	if (params && params.main) {
	    widget.main = params.main;
	    widget.sidebar = params.sidebar;
	}
	var content = widget.main;
	var sidebar = widget.sidebar;

	if (! stm.user) {
	    content.innerHTML = "<div class='alert alert-info'>You need to be logged in to use this page</div>";
	    return;
	}

	// help text
	sidebar.setAttribute('style', 'padding: 10px;');
	var sidehtml = '<h3><img style="height: 20px; margin-right: 10px; margin-top: -4px;" src="Retina/images/help.png">frequent questions</h3><dl>';
	sidehtml += '<dt>'+widget.expander()+'File Formats</dt><dd style="display: none;">Sequence files need to be in fastq or SFF format. Barcode files need to be plain text, tab separated files containing the barcode sequence and the target file name. You can upload compressed / archived files with the formats zip, gz, tar and tar.gz. They will be automatically expanded after the upload is completed.<br><br></dd>';
	sidehtml += '<dt>'+widget.expander()+'Demultiplexing</dt><dd style="display: none;">You must demultiplex uploaded sequences files before submission to the pipeline. You can do so via the inbox.<br><br></dd>';
	sidehtml += '<dt>'+widget.expander()+'Paired End Merging</dt><dd style="display: none;">You can merge paired end files via the inbox. If the files are multiplexed, you can select a barcode file to perform merging and demultiplexing in a single step.</dd>';
	sidehtml += '</dl>';

	sidebar.innerHTML = sidehtml;

	// title
	var html = '<div class="wizard span12">\
	  <div>\
	    <li class="active"></li>\
	    <a href="#">upload<img src="Retina/images/cloud-upload.png"></a>\
	  </div>\
	  <div class="separator">›</div>\
	  <div>\
	    <li></li>\
	    <a href="?page=submission" class="active">submit<img src="images/forward.png"></a>\
	  </div>\
	  <div class="separator">›</div>\
	  <div>\
	    <li></li>\
	    <a href="?page=pipeline">progress<img src="Retina/images/settings3.png"></a>\
	  </div>\
</div><div style="clear: both; height: 20px;"></div>';

	html += "<div style='margin-bottom: 20px;'><h3>amplicon pipeline upload</h3><p>The submission to the amplicon pipeline is a three step process. First you upload your sequences to your personal inbox. The file will automatically be verified to ensure that it can successfully pass through the pipeline. In the second step you select options and provide some additional information about your files, before you perform the actual submission. In the third phase you can monitor the progress of your job.</p></div>";

	// shockbrowser space
	html += "<div id='browser'></div>";

	content.innerHTML = html;
	
	// check if we have a user
	if (stm.user) {
	    if (widget.browser) {
	    	widget.browser.display({ target: document.getElementById("browser") });
	    } else {
	    	widget.browser = Retina.Widget.create("shockbrowse", { "target": document.getElementById("browser"),
	    							       "width": 900,
	    							       "height": 520,
	    							       "enableUpload": true,
	    							       "customPreview": widget.filePreview,
	    							       "fileUploadCompletedCallback": widget.fileCompleted,
								       "allFileUploadCompletedCallback": widget.allFilesCompleted,
								       "fileDeletedCallback": widget.fileDeleted,
	    							       "detailType": "preview",
	    							       "showDetailBar": false,
	    							       "showFilter": false,
	    							       "showResizer": false,
	    							       "showStatusBar": false,
	    							       "showTitleBar": false,
	    							       "enableDownload": false,
								       "previewChunkSize": 100000,
								       "uploadChunkSize": 1024 * 1024 * 100,
	    							       "enableCompressedDownload": false,
	    							       "showUploadPreview": false,
	    							       "autoDecompress": true,
								       "autoUnarchive": true,
								       "calculateMD5": true,
								       "allowMultiselect": true,
								       "allowMultiFileUpload": true,
								       "customButtons": [ { "title": "download sequence file details",
											    "id": "inboxDetailsButton",
											    "image": "Retina/images/info.png",
											    "callback": widget.downloadInboxDetails } ],
	    							       "user": stm.user,
								       "fileSectionColumns": [
									   { "path": "file.name", "name": "Name", "width": "75%", "type": "file" },
									   { "path": "attributes.data_type", "name": "Type", "width": "25%" }
								       ],
								       "fileDoneAttributes": {
									   "type": "inbox",
									   "id": stm.user.id,
									   "user": stm.user.login,
									   "email": stm.user.email },
								       "blacklist": {
									   "awe_stderr.txt": true,
									   "awe_stdout.txt": true,
									   "submission_parameters.json": true,
										    },
	    							       "uploadRestrictions": [ { "expression": /\.rar$/, "text": 'Invalid archive type. Allowed types are gz, zip and bz2' },
	    										       { "expression": /\.faa$/, "text": "MG-RAST cannot process protein sequences. Please use DNA only." }],
	    							       "preUploadCustom": widget.fileSelectedForUpload,
	    							       "presetFilters": { "type": "inbox", "id": stm.user.id },
	    							       "shockBase": RetinaConfig.shock_url});
	    	widget.browser.loginAction({ action: "login", result: "success", user: stm.user, authHeader: stm.authHeader});
	    }

	    // check if we have enough space to show the sidebar
	    widget.checkScreenWidth();
	    window.onresize = Retina.WidgetInstances.upload[1].checkScreenWidth;

	    widget.AWEJoblist();

	} else {
	    content.innerHTML = "<div class='alert alert-info' style='width: 500px;'>You must be logged in to upload data.</div>";
	}
    };

    // do some convenience checks before the file is uploaded
    widget.fileSelectedForUpload = function (selectedFile, customIndex) {
	var widget = Retina.WidgetInstances.upload[1];

	// detect filetype
	var ret = widget.detectFiletype(selectedFile.name);
	var fileType = ret.fileType;
	var sequenceType = ret.sequenceType;

	var promise = jQuery.Deferred();

	// check if the filename is valid
	if (! selectedFile.name.match(/^[\w\d\.]+$/)) {
	    var html = '<div class="alert alert-error"><strong>Invalid file name</strong> The file name may only contain letters, digits, underscore and ".".</div>';
	    return promise.resolve(html, false, customIndex);
	}

	// get the filereader
	var fileReader = new FileReader();
	fileReader.prom = promise;
	fileReader.customIndex = customIndex;
	fileReader.onerror = function (error) {
	    console.log(error);
	};
	var blobSlice = File.prototype.slice || File.prototype.mozSlice || File.prototype.webkitSlice;

	// check the type of file to be uploaded
	if (fileType == "text" ) {
	    fileReader.onload = function(e) {
		var data = e.target.result;
		var html = "";
		var allow = true;
		var validBarcode = Retina.WidgetInstances.upload[1].validateBarcode(data).valid;
		var allow = true;
		if (validBarcode) {
		    html = "<div class='alert alert-success' style='margin-top: 20px;'>This is a valid barcode file.</div>";
		} else {
		    html = "<div class='alert alert-warning' style='margin-top: 20px;'>This file is not a valid barcode file. Barcode files must have a barcode sequence followed by a tab and a filename in each line, or be an automatically generated QIIME barcode file.</div>";
		    allow = false;
		}
		this.prom.resolve(html, allow, this.customIndex);
	    };
	    fileReader.readAsText(blobSlice.call(selectedFile, 0, selectedFile.size));
	} else if (fileType == "compressed") {
	    var containedType = widget.detectFiletype(selectedFile.name.substr(0, selectedFile.name.lastIndexOf(".")));
	    if (containedType.fileType == "") {
		var html = '<div class="alert alert-warning" style="text-align: left;"><strong>Compressed file without file ending</strong><br>You can upload this file, but the filename does not contain the filetype suffix and it will not be detected as a sequence file.</div>';
		promise.resolve(html, true, customIndex);
	    } else {
		return promise.resolve("", true, customIndex);
	    }
	} else if (fileType == "archive") {
	    var html = '<div class="alert alert-info" style="text-align: left;"><strong>Archive file detected</strong><br>Once the upload has completed, this file will automatically be decompressed and unpacked. If the archive contains sequence files, sequence statistics will automatically be computed.</div>';
	    promise.resolve(html, true, customIndex);
	} else if (fileType == "sequence") {
	    fileReader.onload = function(e) {
		var html = "";
		var data = e.target.result;
		var d = data.split(/\n/);
		var allow = true;
		var type = "unknown";
		var IUPAC = false;
		
		// FASTA
		if (d[0].match(/^>/)) {
		    type = "FASTA";
		} else if (d[0].match(/^@/)) {
		    type = "FASTQ";
		}
		if (type == "FASTA" || type == "FASTQ") {
		    var header = d[0];
		    var seq = d[1].trim();
		    var tooShort = 0;
		    var numSeqs = 1;
		    var invalidSeqs = 0;
		    var headers = {};
		    var numDuplicate = 0;
		    if (type=="FASTA") {
			headers[header] = true;
		    }
		    for (var i=(type=="FASTA"?2:0); i<d.length - 1; i++) {
			var newEntry = false;
			if (type == "FASTA") {
			    if (d[i].match(/^>/)) {
				header = d[i];
				newEntry = true;
			    } else {
				seq += d[i].trim();
			    }
			} else {
			    header = d[i];
			    seq = d[i+1];
			    i += 3;
			}
			if (newEntry || type=="FASTQ") {
			    if (headers.hasOwnProperty(header)) {
				numDuplicate++;
			    } else {
				headers[header] = true;
			    }
			    numSeqs++;
			    
			    // sequence contains invalid characters
			    seq = seq.trim();
			    if (! seq.match(/^[acgtunx-]+$/i)) {
				if (seq.match(/^[acgtunxrykmswbdhv-]+$/i)) {
				    IUPAC = true;
				}
				invalidSeqs++;
			    }
			    if (seq.length < 75) {
				tooShort++;
			    }
			    seq = "";
			}
		    }
		    numSeqs--;
		    tooShort--;
		    var lenInfo = " All of the tested sequences fulfill the minimum length requirement of 75bp.";
		    if (tooShort > 0) {
			lenInfo = " "+tooShort.formatString() + " of the tested sequences are shorter than the minimum length of 75bp. These reads cannot be processed.";
		    }
		    var validInfo = "This is a valid "+type+" file. "+numSeqs.formatString() + " sequences of this file were tested. ";
		    if (invalidSeqs || numDuplicate) {
			validInfo = numSeqs.formatString() + " sequences of this file were tested. ";
			if (invalidSeqs) {
			    validInfo += invalidSeqs.formatString() + " of them contain invalid characters. ";
			    if (IUPAC) {
				validInfo += "It seems the file contains IUPAC ambiguity characters other than N. Allowed characters are GATC UXN- only. ";
			    }
			}
			if (numDuplicate) {
			    validInfo += numDuplicate + " of them contain duplicate headers. ";
			}
			validInfo += "The "+type+" file is not in the correct format for processing.";
			allow = false;
		    }
		    html += '<div class="alert alert-info">'+validInfo+lenInfo+'</div>';
		} else {
		    html = '<div class="alert alert-error">Not a valid sequence file.</div>';
		    allow = false;
		}
		this.prom.resolve(html, allow, this.customIndex);
	    };
	    var tenMB = 1024 * 1024 * 10;
	    fileReader.readAsText(blobSlice.call(selectedFile, 0, selectedFile.size < tenMB ? selectedFile.size : tenMB));
	} else {
	    return promise.resolve("", true, customIndex);
	}
	
	return promise;
    };

    widget.detectFiletype = function (fn) {
	var filetype = "";
	var sequenceType = null;
	if (fn.match(/(tar\.gz|zip|tar\.bz2|tar)$/)) {
	    filetype = "archive";
	} else if (fn.match(/(gz|gzip)$/)) {
	    filetype = "compressed";
	} else if (fn.match(/sff$/)) {
	    sequenceType = "sff";
	    filetype = "sff sequence";
	} else if (fn.match(/(fq|fastq)$/)) {
	    sequenceType = "fastq";
	    filetype = "sequence";
	} else if (fn.match(/txt|barcode$/)) {
	    filetype = "text";
	}
	
	return { fileType: filetype, sequenceType: sequenceType };
    };

    widget.filePreview = function (params) {
	var widget = Retina.WidgetInstances.upload[1];

	var html = "<h5 style='margin-bottom: 0px;'>File Information</h5>";

	var node = params.node;

	if (! node) {
	    console.log(params);
	}

	var fn = node.file.name;

	html += "<table style='font-size: 12px;'>";
	html += "<tr><td style='padding-right: 20px;'><b>filename</b></td><td>"+fn+"</td></tr>";
	html += "<tr><td><b>size</b></td><td>"+node.file.size.byteSize()+"</td></tr>";
	html += "<tr><td><b>creation</b></td><td>"+node.last_modified+"</td></tr>";
	html += "<tr><td><b>md5</b></td><td>"+node.file.checksum.md5+"</td></tr>";
	html += "</table>";

	// detect filetype
	var ret = widget.detectFiletype(fn);
	var filetype = ret.fileType;
	var sequenceType = ret.sequenceType;

	// check data
	var data = params.data;

	var task = null;
	if (task) {
	    html += '<div class="alert alert-info" style="margin-top: 20px;">This file is being processed with '+task+'</div>';
	} else {
	    var fileHash = [];
	    for (var i=0; i<widget.browser.fileList.length; i++) {
		fileHash[widget.browser.fileList[i].file.name] = widget.browser.fileList[i];
	    }
	    if (filetype == "sff sequence") {
		var noSuffix = node.file.name.replace(/sff$/, "");
		html += "<h5 style='margin-top: 20px; margin-bottom: 0px;'>File Actions ("+filetype+")</h5>";
		if (fileHash.hasOwnProperty(noSuffix+"fastq")) {
		    html += "<div class='alert alert-info' style='margin-top: 20px;'>This file has already been converted to fastq.</div>";
		} else {
		    html += "<div id='convert'><button class='btn btn-small' onclick='Retina.WidgetInstances.upload[1].sff2fastq(\""+node.id+"\");'>convert to fastq</button></div>";
		}
	    }
	    if (filetype == "excel") {
		// check if this file has already been validated
		if (node.attributes.hasOwnProperty('data_type') && node.attributes.data_type == 'metadata') {
		    html += '<div class="alert alert-success">This file contains valid metadata.</div>';
		} else {

		    // check if this is valid metadata
		    html += '<div id="metadataValidation" style="padding-top: 10px;"><div class="alert alert-info"><img src="Retina/images/waiting.gif" style="margin-right: 10px; width: 16px;"> validating metadata...</div></div>';
		    var url = RetinaConfig.mgrast_api+'/metadata/validate';
		    jQuery.ajax(url, {
			data: { "node_id": node.id },
			success: function(data){
			    Retina.WidgetInstances.upload[1].metadataValidationResult(data, node.id);
			},
			error: function(jqXHR, error){
			    console.log(error);
			    console.log(jqXHR);
			},
			crossDomain: true,
			headers: stm.authHeader,
			type: "POST"
		    });
		}
	    }
	    if (filetype == "text") {
		// check if this is a barcode file
		if (! params.data) {
		    html += "<div class='alert alert-info' style='margin-top: 20px;'>This file is empty.</div>";
		} else {
		    var validation = Retina.WidgetInstances.upload[1].validateBarcode(params.data);
		    var barcodes = validation.barcodes;
		    var validBarcode = validation.valid;
		    if (validBarcode) {
			var options = "";
			var indexOptions = "";
			var alreadyDemultiplexed = false;
			for (var i=0; i<widget.browser.fileList.length; i++) {
			    var fn = widget.browser.fileList[i].file.name;
			    if (fn.match(/\.fastq$/) || fn.match(/\.fq$/)) {
				var sel = "";
				if (fn.substr(0, fn.lastIndexOf(".")) == node.file.name.substr(0, node.file.name.lastIndexOf("."))) {
				    sel = " selected";
				}
				indexOptions += "<option value='"+widget.browser.fileList[i].id+"'>"+fn+"</option>";
				options += "<option value='"+widget.browser.fileList[i].id+"'"+sel+">"+fn+"</option>";
				fn = fn.replace(/\.fastq$/, "").replace(/\.fq$/, "");
				if (barcodes.hasOwnProperty(fn)) {
				    alreadyDemultiplexed = true;
				    break;
				}
			    }
			}
			if (alreadyDemultiplexed) {
			    html += "<div class='alert alert-info' style='margin-top: 20px;'>The demultiplex files of these barcodes have already been generated.</div>";
			} else {
			    html += "<h5>Demultiplex</h5><div id='convert'><p>This is a valid barcode file. Select a file below to demultiplex:</p>";
			    html += "<select id='demultiplexFile' style='width: 100%;'>";
			    html += options;
			    html += "</select>";
			    html += "<p>select index file if applicable</p>";
			    html += "<select id='demultiplexIndex' style='width: 100%;'><option>-</option>";
			    html += indexOptions;
			    html += "</select>";
			    html += "barcodes are reverse complements <input type='checkbox' id='demultiplexIsReverseComplement' style='margin-top: -2px;'><div style='height: 10px;'></div>";
			    html += "<button class='btn btn-mini' onclick='Retina.WidgetInstances.upload[1].demultiplex(\""+node.id+"\");'>demultiplex</button></div>";
			}
		    } else {
			html += "<div class='alert alert-warning' style='margin-top: 20px;'>This file is not a valid barcode file. Barcode files must have a barcode sequence followed by a tab and a filename in each line, or be an automatically generated QIIME barcode file.</div>";
		    }
		}
	    }
	    if (filetype == "sequence") {
		html += "<h5 style='margin-top: 20px; margin-bottom: 0px;'>Sequence Information";

		// tell user detail info about the sequence
		if (node.attributes.hasOwnProperty('stats_info') && node.attributes.stats_info.hasOwnProperty('bp_count')) {
		    
		    // fastq files can have the "join paired ends" option
		    if (sequenceType == "fastq") {
			html += "<button class='btn btn-mini' style='float: right;' onclick='if(this.innerHTML==\"join paired ends\"){this.innerHTML=\"show sequence info\";this.previousSibling.textContent=\"Join Paired Ends\";}else{this.innerHTML=\"join paired ends\";this.previousSibling.textContent=\"Sequence Information\";}jQuery(\"#joinPairedEndsDiv\").toggle();jQuery(\"#seqInfoDiv\").toggle();'>join paired ends</button>";
		    }

		    // demultiplex button
		    html += "<button class='btn btn-mini' style='float: right;' onclick='alert(\"Please select the barcode file on the left to demultiplex\")'>demultiplex</button>";

		    html += "</h5><div id='joinPairedEndsDiv' style='display: none; font-size: 12px; padding-top: 10px;'>";
		    html += "<input type='text' style='display: none;' value='"+node.id+"' id='jpeFileA'>";
		    var opts = [];
		    var txtOpts = "<option>- none -</option>";
		    var indOpts = "<option>- none -</option>";
		    var bestHit = 0;
		    var selectedOpt = 0;
		    var partial = "";
		    var currFn = node.file.name;
		    for (var i=0; i<widget.browser.fileList.length; i++) {
			var fn = widget.browser.fileList[i].file.name;

			// a file cannot be joined on itself
			if (fn == currFn) {
			    continue;
			}

			if (fn.match(/\.fastq$/) || fn.match(/\.fq$/)) {
			    // check if the filename is similar to the current filename
			    for (var h=0; h<fn.length; h++) {
				if (fn.charAt(h) != currFn.charAt(h)) {
				    if (h>bestHit) {
					bestHit = h;
					selectedOpt = opts.length;
					partial = fn.substr(0, h);
				    }
				    break;
				}
			    }
			    opts.push(widget.browser.fileList[i]);
			    indOpts += "<option value='"+widget.browser.fileList[i].id+"'>"+fn+"</option>";
			} else if (fn.match(/\.txt$/)) {
			    txtOpts += "<option value='"+widget.browser.fileList[i].id+"'>"+fn+"</option>";
			}
		    }
		    for (var i=0; i<opts.length; i++) {
			var sel = "";
			if (i==selectedOpt) {
			    sel = " selected";
			}
			opts[i] = "<option value='"+opts[i].id+"'"+sel+">"+opts[i].file.name+"</option>";
		    }
		    opts = opts.join("\n");
		    html += "<span style='position: relative; bottom: 4px;'>file to join</span><select id='jpeFileB' style='font-size: 12px; height: 25px; margin-left: 10px; width: 350px;'>"+opts+"</select><br>";
		    html += "remove non-overlapping paired-ends <input type='checkbox' checked='checked' id='jpeRetain' style='margin-top: -2px;'><div style='height: 1px;'></div>";
		    html += "<h5>Optional Demultiplex</h5>";
		    html += "<span style='position: relative; bottom: 4px;'>index file</span><select id='jpeIndexFile' style='font-size: 12px; height: 25px; margin-left: 14px; width: 350px;'>"+indOpts+"</select><br>";
		    html += "<span style='position: relative; bottom: 4px;'>Barcode file (optional)</span><select id='jpeBarcode' style='font-size: 12px; height: 25px; margin-left: 10px; width: 286px;'>"+txtOpts+"</select><br>";
		    html += "barcodes are reverse complements <input type='checkbox' id='jpeIsReverseComplement' style='margin-top: -2px;'><div style='height: 10px;'></div>";
		    html += "<span style='position: relative; bottom: 4px;'>Output file name</span><div class='input-append'><input type='text' placeholder='output file name' id='jpeOutfile' style='font-size: 12px; height: 16px; margin-left: 3px;' value='"+(partial.length > 1 ? partial + ".fastq" : "")+"'>";
		    html += "<button class='btn btn-small' onclick='Retina.WidgetInstances.upload[1].joinPairedEnds();'>join paired ends</button></div>";
		    html += "</div><div id='seqInfoDiv'>";

		    // check if all sequences have a unique id
		    var unique = parseInt(node.attributes.stats_info.unique_id_count);
		    var seqcount = parseInt(node.attributes.stats_info.sequence_count);
		    var minlen = parseInt(node.attributes.stats_info.length_min);
		    var maxlen = parseInt(node.attributes.stats_info.length_max);

		    html += "<div style='text-align: left; font-size: 12px;'>";
		    html += "<div style='font-weight: bold;'>basepair count</div><div>This file contains "+parseInt(node.attributes.stats_info.bp_count).formatString()+"bp of "+node.attributes.stats_info.sequence_content+" sequence containing "+parseInt(node.attributes.stats_info.ambig_char_count).formatString()+" ambiguous characters.</div>";
		    html += "<div style='font-weight: bold;'>sequence count</div><div>This file contains "+seqcount.formatString()+" sequences "+(minlen < maxlen ? "ranging from "+minlen.formatString()+"bp to "+maxlen.formatString()+"bp and averaging "+parseInt(node.attributes.stats_info.average_length).formatString()+"bp in length (std.deviation from average length "+node.attributes.stats_info.standard_deviation_length+")." : " all "+minlen+"bp in length.")+(unique == seqcount ? " All of them have unique ids." : " Only "+unique.formatString()+" have unique ids.")+" The average GC-content is "+node.attributes.stats_info.average_gc_content+"% (std.deviation "+node.attributes.stats_info.standard_deviation_gc_content+") and GC-ratio "+node.attributes.stats_info.average_gc_ratio+" (std.deviation "+node.attributes.stats_info.standard_deviation_gc_ratio+"). </div>";
		    html += "<div style='font-weight: bold;'>sequence type</div><div>We think this is a"+(node.attributes.stats_info.sequence_type == "WGS" ? " shotgun metagenome" : "n amplicon metagenome")+" "+(node.attributes.stats_info.sequencing_method_guess == "other" ? (node.attributes.stats_info.sequencing_method_guess == "assembled" ? "sequenced with "+node.attributes.stats_info.sequencing_method_guess+"." : "of assembled reads.") : "but were unable to guess the sequencing technology.")+"</div>";
		    html += "</div>";

		    html += "</div>";
		} else {
		    widget.statsCalculation(node);
		    
		    html += "</h5><div class='alert alert-info'>calculation of sequence stats in progress <button class='btn btn-small' title='refresh' style='margin-left: 15px;' onclick='Retina.WidgetInstances.upload[1].browser.updateData();'><img src='Retina/images/loop.png' style='width: 12px; margin-top: -2px;'></button></div>";
		}
	    }
	    
	    html += "<h5 style='margin-top: 10px;'>Delete File</h5>";
	    html += "<button class='btn btn-small btn-danger' onclick='if(confirm(\"Really delete this file?\\nThis cannot be undone!\")){Retina.WidgetInstances.upload[1].browser.removeNode({node:\""+node.id+"\"});}'>delete file</button>";
	}

	return html;
    };

    widget.fileCompleted = function (data, currentIndex) {
	var widget = Retina.WidgetInstances.upload[1];

	// get node from data
	var nodes = data.data;

	// check if something went wrong
	if (nodes === null) {
	    console.log('error in archive unpacking');
	    return;
	}

	// check if this is an archive
	if (typeof nodes.length !== 'number') {
	    nodes = [ nodes ];
	}

	// iterate over the nodes
	for (var i=0; i<nodes.length; i++) {

	    var node = nodes[i];

	    // set permissions for mgrast
	    widget.browser.addAcl({node: node.id, acl: "all", uuid: "mgrast"});
	    
	    // calculate sequence stats
	    if (widget.detectFiletype(node.file.name).fileType == "sequence") {
		widget.statsCalculation(node);
	    }
	    else if (widget.detectFiletype(node.file.name).fileType == "sff sequence") {
		widget.sff2fastq(node);
	    }
	    // validate metadata
	    else if (widget.detectFiletype(node.file.name).fileType == "excel") {
		var url = RetinaConfig.mgrast_api+'/metadata/validate';
		jQuery.ajax(url, {
		    data: { "node_id": node.id },
		    success: function(data){ },
		    error: function(jqXHR, error){ },
		    crossDomain: true,
		    headers: stm.authHeader,
		    type: "POST"
		});
	    }
	}
    };

    widget.allFilesCompleted = function (data) {
	var widget = Retina.WidgetInstances.upload[1];

	widget.getRunningInboxActions();
	widget.browser.preserveDetail = true;
	widget.browser.updateData();
    };

    widget.fileDeleted = function (deleted, node) {
	var widget = Retina.WidgetInstances.upload[1];

	if (deleted && node) {
	    if (node.attributes.hasOwnProperty('actions')) {
		for (var i=0; i<node.attributes.actions.length; i++) {
		    widget.cancelInboxAction(node.attributes.actions[i].id);
		}
	    }
	}
    };

    // Inbox actions
    widget.statsCalculation = function (node) {
	var widget = this;
	widget.AWESubmission({ "variables": { "seq_file_id": node.id,
					      "seq_file": node.file.name,
					      "file_type": "fastq" },
			       "workflow": "seq_stats" });
    };

    widget.sff2fastq = function (node) {
	var widget = this;
	widget.AWESubmission({ "variables": { "sff_file_id": node.id,
					      "sff_file": node.file.name,
					      "fastq_file": node.file.name.replace(/sff$/, "fastq") },
			       "workflow": "sff_to_fastq" });
    };

    widget.demultiplex = function (barcodeID) {
	var widget = this;
	widget.AWESubmission({ "variables": { "seq_file": seq.file.name,
					      "seq_file_id": seq.id,
					      "bar_file": bar.file.name,
					      "bar_file_id": bar.id,
					      "file_type": seq.attributes.stats_info.file_type },
			       "workflow": "demultiplex" });
    };

    widget.joinPairedEnds = function () {
	var widget = Retina.WidgetInstances.upload[1];

	var fileA = document.getElementById('jpeFileA').value;
	var fileB = document.getElementById('jpeFileB').options[document.getElementById('jpeFileB').selectedIndex].value;
	var outfile = document.getElementById('jpeOutfile').value;

	// check if the outfile name is valid
	if (! outfile.match(/^[\w\d\.]+$/)) {
	    alert("The selected output file name is invalid.\nFile names may only contain letters, digits, '.' and '_' characters.");
	    return;
	}

	var retain = document.getElementById('jpeRetain').getAttribute('checked') ? 1 : 0;
	var indexFile = document.getElementById('jpeIndexFile').options[document.getElementById('jpeIndexFile').selectedIndex].value;
	var d = { "pair_file_1": fileA,
		  "pair_file_2": fileB,
		  "output": outfile,
		  "retain": retain };

	if (document.getElementById('jpeIndexFile').selectedIndex > 0) {
	    d.index_file = indexFile;
	    if (indexFile == fileB) {
		alert("join file and index file may not be the same");
		return;
	    }
	}

	var barcode = document.getElementById('jpeBarcode');
	if (barcode.selectedIndex > 0) {
	    d.barcode_file = document.getElementById('jpeBarcode').options[document.getElementById('jpeBarcode').selectedIndex].value;
	    d.rc_index = document.getElementById('jpeIsReverseComplement').checked;
	}

	var url = RetinaConfig.mgrast_api+'/inbox/pairjoin' + (barcode.selectedIndex > 0 ? "_demultiplex" : "");
	jQuery.ajax(url, {
	    data: d,
	    success: function(data){
		document.getElementById('joinPairedEndsDiv').innerHTML = '<div class="alert alert-info" style="margin-top: 20px;">This file is being processed with join paired ends</div>';
		Retina.WidgetInstances.upload[1].getRunningInboxActions();
	    },
	    error: function(jqXHR, error){
		document.getElementById('joinPairedEndsDiv').innerHTML = '<div class="alert alert-error" style="margin-top: 20px;">join paired ends failed</div>';
		console.log(error);
		console.log(jqXHR);
	    },
	    crossDomain: true,
	    headers: stm.authHeader,
	    type: "POST"
	});

	document.getElementById('joinPairedEndsDiv').innerHTML = "<img src='Retina/images/waiting.gif' style='width: 32px;'>";
    };

    // generate a tab separated file that shows details about the files in the inbox
    widget.downloadInboxDetails = function () {
	var widget = Retina.WidgetInstances.upload[1];

	var files = widget.browser.fileList;
	var sequences = [];
	for (var i=0; i<files.length; i++) {
	    if (files[i].attributes.hasOwnProperty('data_type') && files[i].attributes.data_type == "sequence") {
		sequences.push(files[i]);
	    }
	}
    
	var txt = [ "no sequence files in your inbox" ];
	if (sequences.length) {
	    var seqHead = Retina.keys(sequences[0].attributes.stats_info).sort();
	    txt = [ seqHead.join("\t") ];
	    for (var i=0; i<sequences.length; i++) {
		var row = [];
		if (sequences[i].attributes.stats_info.hasOwnProperty("bp_count")) {
		    for (var h=0; h<seqHead.length; h++) {
			row.push(sequences[i].attributes.stats_info[seqHead[h]]);
		    }
		} else {
		    row = [ "sequence statistics calculation incomplete" ]
		}
		txt.push(row.join("\t"));
	    }
	}
	
	stm.saveAs(txt.join("\n"), "inbox.txt");
    };

    // contact AWE
    widget.AWEQuery = function (params) {
	var widget = this;
	
	// set default values
	var url = RetinaConfig.awe.url;
	var method = params.method || "GET";
	var resource = params.resource || "job";
	var query = "";
	
	// check if we have a query
	if (params.query) {
	    var qarray = [];
	    for (var i in params.query) {
		if (params.query.hasOwnProperty(i)) {
		    if (typeof params.query[i] == 'object') {
			for (var h=0; h<params.query[i].length; h++) {
			    qarray.push(i+"="+params.query[i][h]);
			}
		    } else {
			qarray.push(i+"="+params.query[i]);
		    }
		}
	    }
	    query = "?query&" + qarray.join("&");
	}

	// construct the url
	url += resource + query;
	var ajaxParams = {
	    success: function(data){
		params.callback.call(Retina.WidgetInstances.upload[1], data);
	    },
	    error: function(jqXHR, error){
		Retina.WidgetInstances.upload[1].handleAWEError(jqXHR);
	    },
	    crossDomain: true,
	    headers: { "Authorization": "OAuth "+stm.user.token },
	    type: method,
	    processData: false
	}

	if (params.data) {
	    ajaxParams.headers["Datatoken"] = stm.user.token;
	    ajaxParams.data = params.data;
	    ajaxParams.contentType = false;
	}   

	// perform the query
	jQuery.ajax(url, ajaxParams);
    };

    // AWE queries
    widget.AWESubmission = function (params) {
	var widget = this;
	
	params.variables.job_name = stm.user.login+"_"+params.workflow+(params.job ? params.job : "");
	params.variables.user_id = stm.user.id;
	params.variables.user_name = stm.user.login;
	params.variables.user_email = stm.user.email;
	params.variables.clientgroups = RetinaConfig.awe.clientgroups;
	params.variables.shock_url = RetinaConfig.shock_url;
	var template = params.template || "submission";
	jQuery.ajax(RetinaConfig.awe.workflows+"/"+params.workflow+".awf", {
	    success: function(jqXHR){

	    },
	    error: function(jqXHR){
		var data = jqXHR.responseText;
		var widget = Retina.WidgetInstances.upload[1];
		for (var i in params.variables) {
		    if (params.variables.hasOwnProperty(i)) {
			data = data.replace(new RegExp("\\[%\\s*"+i+"\\s*%\\]","ig"), params.variables[i]);
		    }
		}
		data = new Blob([ data ], { "type" : "text\/json" });
		var form = new FormData();
		form.append('upload', data, "workflow.awf");
		widget.AWEQuery( { "method": "POST", "data": form, "callback": widget.AWEResponse } );

		Retina.WidgetInstances.upload[1].handleAWEError(jqXHR);
	    }
	});
    };

    widget.AWEJoblist = function () {
	var widget = this;

	widget.AWEQuery({ "query": { "info.user": stm.user.id,
				     "state": [ "queued", "in-progress", "suspend", "error", "init", "pending" ],
				     "offset": 0,
				     "limit": 500 },
			  "callback": widget.AWEJoblistResponse });
    };

    // AWE responses
    widget.AWESubmissionResponse = function(response) {
	var widget = this;

	console.log(response);
    };

    widget.AWEJoblistResponse = function (response) {
	var widget = this;

	
    };

    widget.handleAWEError = function (call) {
	var widget = this;
	
    }

    // helper functions
    widget.expander = function () {
	return '<span onclick="if(this.getAttribute(\'exp\')==\'n\'){this.parentNode.nextSibling.style.display=\'\';this.innerHTML=\'▾\';this.setAttribute(\'exp\',\'y\');}else{this.parentNode.nextSibling.style.display=\'none\';this.innerHTML=\'▸\';this.setAttribute(\'exp\',\'n\');}" style="cursor: pointer; margin-right: 5px;" exp=n>▸</span>';
    };

    widget.checkScreenWidth = function () {
	var widget = this;

	var w = jQuery(window).width();
	var sb = document.getElementById('sidebarResizer');
	var c = document.getElementById('content');
	if (w < 1200) {
	    c.style.paddingLeft = "10px";
	    c.className = "span9";
	    if (sb.getAttribute('status') == "on") {
		sb.click();
	    }
	} else if (w < 1520) {
	    c.style.paddingLeft = "10px";
	    c.className = "span9";
	    if (sb.getAttribute('status') == "off") {
		sb.click();
	    }
	} else {
	    c.style.paddingLeft = "0px";
	    c.className = "span7 offset1";
	    if (sb.getAttribute('status') == "off") {
		sb.click();
	    }
	}
    };

    widget.validateBarcode = function (data) {
	var d;
	if (data.match(/\n/)) {
	    d = data.split(/\n/);
	} else {
	    d = data.split(/\r/);
	}

	var barcode = 0;
	var samplename = 1;
	var barcodes = {};
	
	// test for QIIME barcode file
	if (d[0].match(/^\#SampleID\tBarcodeSequence/i)) {
	    d.shift();
	    barcode = 1;
	    samplename = 0;
	}
	
	var validBarcode = true;
	for (var i=0; i<d.length; i++) {
	    if (d[i].length == 0) {
		continue;
	    }
	    var l = d[i].split(/\t/);
	    if (! (l[barcode].match(/^[atcg]+$/i) && l[samplename].match(/^(\S)+$/))) {
		validBarcode = false;
		console.log(l);
		break;
	    } else {
		barcodes[l[samplename]] = l[barcode];
	    }
	}

	return { "valid": validBarcode, "barcodes": barcodes };
    };
    
})();
