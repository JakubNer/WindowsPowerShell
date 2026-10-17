."menu.ps1"

# Depends on properly configured properties in environment:
#
#   * $wspcs = $(ls C:\Users\jner\wspc)
#   * ${global:wspc} = C:\Users\jner\wspc\kaos
#   * ${env:wspc_key} = kaos

###############################################################################
## CONFIG

#
# Initial config requireing only $PROFILE definitions.
#

$options = "edit this",
		   "activate workspace",
           "change hosts file",
           "change IBSPARMS.INI",
           "get standalone-mccg.properties",
           "view TNSNAMES.ORA",
           "init :: open up git",
           "init :: build server code",
           "init :: set PB12 writable",
           "init :: copy IBSPlatformClient.jar to PB12",
           "init :: modify IBSPARMS.INI to DEV in PB12",
           "init :: build jboss",
           "init :: copy rules engine and log4j files",
           "init :: registry changes",
		   "generate CTAGS"
           
$options = @($options)

$workspaces =  gci ${global:wspcs} | %{$_.Name}

###############################################################################
## Helper Functions

function ActivateRoot {
    ## Activate workspace root
    $wspc_key = Menu $workspaces "WHICH WORKSPACE:"
    Invoke-Expression "& $wspcs/$wspc_key/jjactivate.ps1"
}

###############################################################################
## Main

function EX ($what) {
	Write-Host ">>> JTN >>>" $what;
	iex $what;
}

$selection = Menu $options "CHOOSE YOUR COMMAND (active workspace::${global:wspc_name}):"

Switch ($selection) {
	"edit this" {
		jjnp $MyInvocation.MyCommand.Definition
	}
    "activate workspace" {
        ActivateRoot;
        break;
    }
    "change hosts file" {
        EX "& jje C:\Windows\System32\drivers\etc\hosts"        
    }
    "change IBSPARMS.INI" {
        EX "& jjnp ${global:wspc}\mccg-client-suite\pb-client\src\main\PB\ibs\ibsparms.ini"    
    }
    "get standalone-mccg.properties" {
        $hostip = Read-Host 'host?'
        jjscp "jboss@${hostip}:/opt/mccg/wildfly-10-as/standalone/configuration/standalone-mccg.properties ${global:jboss}\standalone\configuration"
        break;
    }
    "view TNSNAMES.ORA" {
        EX "& jjnp C:\app\product\11.2.0\client_1\network\admin\TNSNAMES.ORA"
    }
    "init :: open up git" {
        EX '& git config --global url."https://".insteadOf git://';
        break;
    }
    "init :: build server code" {
        EX "& mvn clean install -f ${global:wspc}\mccg-server-suite -DskipTests=true";
        break;
    }
    "init :: set PB12 writable" {
        attrib -R ${global:wspc}\mccg-client-suite\pb-client\src\main\PB
        get-childitem ${global:wspc}\mccg-client-suite\pb-client\src\main\PB -recurse | %{ attrib -R $_.fullName }
        break;
    }
    "init :: copy IBSPlatformClient.jar to PB12"   {
        EX "& cp ${global:wspc}\mccg-server-suite\ibs\ibs-platform-client\target\IBSPlatformClient.jar ${global:wspc}\mccg-client-suite\pb-client\src\main\PB\ibs"
        break;
    }
    "init :: modify IBSPARMS.INI to DEV in PB12"   {
        Write-Host "Set 'ServerName' as 'DEV' in ${global:wspc}\mccg-client-suite\pb-client\src\main\PB\ibs\IBSPARMS.INI"
        (cat "${global:wspc}\mccg-client-suite\pb-client\src\main\PB\ibs\IBSPARMS.INI") | % { $_ -replace "^ServerName=.*$","ServerName= DEV" } | set-content "${global:wspc}\mccg-client-suite\pb-client\src\main\PB\ibs\IBSPARMS.INI"
        break;
    }
    "init :: build jboss" {
        EX "& mvn clean install -Peclipse -f ${global:jboss_root}";
        if(!(Test-Path -Path ${global:logs} )){
           New-Item -ItemType directory -Path ${global:logs}
        }
        break;
    }
    "init :: copy rules engine and log4j files" {
        EX "& cp ${global:wspc}\mccg-server-suite\ibs\ibs-platform\target\IBSPlatform.jar ${global:jboss}\rulesengine\classpath\IBSPlatform.jar";
        EX "& cp ${global:wspc}\mccg-server-suite\ibs\ibs-common\target\ibs-common-*-SNAPSHOT.jar ${global:jboss}\rulesengine\classpath\IBSCommon.jar"
        EX "& cp ${global:wspc}\mccg-server-suite\common-modules\common-services\security-service\target\security-service-*-SNAPSHOT.jar ${global:jboss}\rulesengine\classpath\SecurityService.jar"
        if (test-path "C:\Program Files (x86)\Sybase\Shared\PowerBuilder\WEB-INF\lib\log4j-1.2.8.jar") {
            EX "& del 'C:\Program Files (x86)\Sybase\Shared\PowerBuilder\WEB-INF\lib\log4j-1.2.8.jar'";
        }
        EX "& cp ${global:wspc}\mccg-client-suite\pb-client\src\main\PB\ibs\log4j.jar 'C:\Program Files (x86)\Sybase\Shared\PowerBuilder\WEB-INF\lib'"
        break;
    }
    "init :: registry changes" {
        set-itemproperty "HKLM:\SOFTWARE\Wow6432Node\Sybase\PowerBuilder\12.0\Java\PBIDEConfig\PBSysclasspath\" "11" "C:\Program Files (x86)\Sybase\Shared\PowerBuilder\WEB-INF\lib\log4j.jar"
        break;
    }
	"generate CTAGS" {
		EX "& ctags --options=$scripts\.ctags --recurse=yes -f ${global:wspc}\mccg-client-suite\pb-client\src\main\PB\TAGS ${global:wspc}\mccg-client-suite\pb-client\src\main\PB";
	}
}
