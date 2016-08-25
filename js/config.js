var RetinaConfig = {
    "authResources": { "default": "MG-RAST",
		       "MG-RAST": { "icon": "MGRAST_favicon.ico",
		       		    "prefix": "mggo4711",
		       		    "keyword": "Authorization",
		       		    "url": "https://api.metagenomics.anl.gov?verbosity=verbose",
		       		    "useHeader": true,
				    "loginField": "login" }
		     },
    "authentication": true,
    
    "mgrast_api": "http://api-dev.metagenomics.anl.gov",
    "shock_url": "http://shock.metagenomics.anl.gov",
    "awe_url": "http://awe.metagenomics.anl.gov",
    
    "awe": { "url": "http://140.221.67.82:8001/",
	     "clientgroups": "Inbox",
	     "workflows": "workflows" }
};
