local module = {
	
	playerReport_Config = { -- / Config for Player Report
		webhook = "https://discord.com/api/webhooks/1489209586891100185/-fEU5ugZI2DEG1NFLD2P9-relYkqm2e_4eFiBG6oBjBHDd51HYN9teGOnNBSUlTP-ijT"; -- / Webhook URL
			pingEnabled = true;
				pingRoleId = "953345940708818984"; -- / Role ID you wish to ping
		
		commands = { -- / Chat Commands to open PlayerReportUI / Not case sensitive
			"!report";
		};
		
		cooldown = true;
			cooldownTime = 1; -- / In minutes
	};
	
	bugReport_Config = { -- / Config for Bug Report
		webhook = "https://discord.com/api/webhooks/1489209083176423595/bm_hfhGNINhtiedJhAWA0aLWmEoPgbTNCHMbO8v110CXCKWBMcy3T92hovswalpczHF4"; -- / Webhook URL
			pingEnabled = true;
				pingRoleId = "953345940708818984"; -- / Role ID you wish to ping

		bugTypes = { -- / Up to 5 bug types
			"Building";
			"Scripting";
			"UI"
		};
		
		commands = { -- / Chat Commands to open BugReportUI / Not case sensitive
			"!bug";
		};

		cooldown = true;
			cooldownTime = 1; -- / In minutes
	}
}

return module
