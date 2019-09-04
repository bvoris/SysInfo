#Machine Inventory 
# Created By Brad Voris 
# Clean no frills machine inventory 
 
#Computer Name 
$HN = "$env:computername.$env:userdnsdomain" 
 
#Date 
$dated = (Get-Date -format F) 
 
#Uptime 
$uptime = [Management.ManagementDateTimeConverter]::ToDateTime( (gwmi Win32_OperatingSystem -Comp localhost).LastBootUpTime ) 
 
#Boot Config  
$BootConfig = Get-WmiObject -Class Win32_BootConfiguration | Select ConfigurationPath | ConvertTo-Html 
 
#System Manufacturing Information  
$SystemInfo = Get-WmiObject -Class Win32_ComputerSystem | Select Model,Manufacturer,PrimaryOwnerName,SystemType |ConvertTo-Html 
 
#BIOS Information  
$BIOS = Get-WMIObject -Class Win32_BIOS | Select  Manufacturer , Version | ConvertTo-Html 
 
#Operating System 
$os = Get-WMIObject Win32_OperatingSystem | Select @{Name="Operating System"; Expression={$_.caption}}, @{Name="Architecture"; Expression={$_.OSArchitecture}}, @{Name="Service Pack"; Expression={$_.ServicePackMajorVersion}} | ConvertTo-Html 
 
#PowerShell Version 
$PowerShellVersion = Get-Host | Select-Object @{Name="Power Shell Version"; Expression={$_.Version}} | ConvertTo-Html 
 
#Processor 
$Processor = Get-WMIObject Win32_Processor | select Name | ConvertTo-Html 
 
#Memory 
$Memory = Get-WMIObject Win32_OperatingSystem | select  @{Name="Total Memory"; Expression={[math]::Round($_.TotalVisibleMemorySize/1KB)}}, @{Name="Free Physical Memory"; Expression={[math]::Round($_.FreePhysicalMemory/1KB)}} | ConvertTo-Html 
 
#Pagefile 
$Pagefile = Get-WMIObject Win32_OperatingSystem | select @{Name="Total Pagefile Size"; Expression={[math]::Round($_.TotalVirtualMemorySize/1KB)}}, @{Name="Free Pagefile Memory"; Expression={[math]::Round($_.FreeVirtualMemory/1KB)}} | ConvertTo-Html 
 
#Network IP Configuration  
$Network = Get-WMIObject Win32_NetworkAdapterConfiguration | Select Description, @{Name="IP Address"; Expression={$_.IPAddress}},@{Name="Domain"; Expression={$_.DNSDomain}},@{Name="DNS Servers"; Expression={$_.DNSServerSearchOrder}},@{Name="Default Gateway"; Expression={$_.DefaultIPGateway}}  | ConvertTo-Html 
 
#Storage Capcity information 
$StorageCap = Get-WMIObject -computer "localhost" win32_logicaldisk | select @{Name="Drive"; Expression={$_.deviceid}}, @{Name="Total Space"; Expression={($_.size/1GB).tostring("0.00")}},@{Name="Free Space"; Expression={($_.freespace/1GB).tostring("0.00")}}  | ConvertTo-Html 
 
#Drive information 
$DriveInfo = Get-WMIObject -computer "localhost" win32_logicaldisk | select Model, description, mediatype, partitions, status | ConvertTo-Html 
 
#Start-up Programs 
$Startup = Get-WMIObject Win32_StartupCommand | Select-Object Name, @{Name="Application Command"; Expression={$_.command}},Location | ConvertTo-Html 
 
#List running services 
$Services = Get-Service | Where-Object {$_.status -eq "running"} | Select-Object DisplayName,Status | ConvertTo-Html 
 
#Software installed 
$Software = Get-WMIObject win32_Product  -Comp localhost | Select Name,Version,@{Name="Install Date"; Expression={$_.Installdate}},Vendor | ConvertTo-Html 
 
#System Log errors 
$SysEvent = Get-Eventlog -Logname system -Newest 2000  
$SysError = $SysEvent | Where-Object {$_.EntryType -like 'Error' -or $_.EntryType -like 'Warning'} | Sort-Object TimeWritten | Select EventID, Source, TimeWritten, Message | ConvertTo-Html 
 
#Security Log errors 
$SecEvent = Get-Eventlog -Logname system -Newest 2000  
$SecError = $SecEvent | Where-Object {$_.EntryType -like 'Audit Failure' -or $_.EntryType -like 'Warning'} | Sort-Object TimeWritten | Select EventID, Source, TimeWritten, Message | ConvertTo-Html 
 
#HTML Heading 
$htmlhead = @" 
<!DOCTYPE html> 
<HEAD> 
<META charset="UTF-8"> 
<TITLE>System Information Report</TITLE> 
<STYLE> 
table { 
    border-collapse: collapse; 
} 
 
table, td, th { 
    border: 0px solid black; 
} 
</STYLE> 
</HEAD> 
"@ 
 
#HTML Body for report 
$htmlbody = @" 
 
<CENTER> 
<TABLE cellpadding="5" cellspacing="10"> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><Font size=5><B>$HN System Information Report</B></font></CENTER></TD></BR> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER><Font size=3>$dated</CENTER></TD><BR /> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER><Font size=3>Last system boot : $uptime</CENTER></TD><BR /> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER><I>Purpose:</I> This report is general system information for $HN.</CENTER></TD> 
    </TR> 
</CENTER> 
<BR /><BR /> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="ToC">Table of Contents</A></B></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER> 
        <A HREF="#MANU">Manufacturer Information</A></BR> 
        <A HREF="#BIOS">Bios Information</A></BR> 
        <A HREF="#OS">Operating System Information</A></BR> 
        <A HREF="#BOOT">Boot Location Information</A></BR> 
        <A HREF="#PS">PowerShell Information</A></BR> 
        <A HREF="#CPU">Processor Information</A></BR> 
        <A HREF="#MEM">Memory Information</A></BR> 
        <A HREF="#PF">Page File Information</A></BR> 
        <A HREF="#STORE">Storage Information</A></BR> 
        <A HREF="#DRIVE">Drive Information</BR> 
        <A HREF="#NET">Network Information</A></BR> 
        <A HREF="#START">Startup Information</A></BR> 
        <A HREF="#SERVICE">Services Information</A></BR> 
        <A HREF="#SOFT">Software Information</A></BR> 
        <A HREF="#SYS">System Logs</A></BR> 
        <A HREF="#SEC">Security Logs</A></BR> 
        </CENTER> 
        </TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="MANU">Manufacturer Information</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$Systeminfo</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="BIOS">BIOS</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$BIOS</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="OS">Operating System</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$OS</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="BOOT">Boot Location</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$BootConfig</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="PS">PowerShell Version</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
        <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$PowerShellVersion</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="CPU">Processors</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$Processor</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="MEM">Memory</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$Memory</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="PF">Pagefile</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$Pagefile</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="STORE">Storage Information</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$StorageCap</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="DRIVE">Drive Information</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$DriveInfo</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="NET">Network Configuration</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$Network</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="START">Startup Items</A>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></B></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$Startup</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="SERVICE">Current Running Services</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$Services</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="SOFT">Software Inventory</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$Software</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="SYS">System Log Errors</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$SysError</CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #FEF7D6> 
        <TD><CENTER><B><A NAME="SEC">Security Log Errors</A></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<A HREF="#ToC">ToC</A></CENTER></TD> 
    </TR> 
    <TR BGCOLOR= #D9E3EA> 
        <TD><CENTER>$SecError</CENTER></TD> 
    </TR> 
</TABLE> 
 
"@ 
 
$fileDate = get-date -uformat %Y-%m-%d 
 
#Report output & location 
ConvertTo-HTML -head $htmlhead -body $htmlbody | Out-File C:\SystemInformationReport-$fileDate.html
