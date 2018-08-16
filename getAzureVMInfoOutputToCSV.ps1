<##
Create by Mo - kuomingwu@gmail.com
1. 先進行
Login-AzureRmAccount
2. 在下面執行moSolution 的Class範例如下 , 第一個參數放sub 第二個放CSV產生出來路徑
$mo = [moSolution]::new([String] "a4fdde52-f13a-412c-a921-3dc00abc87d9",[String] "C:\temp\a4fdde52-f13a-412c-a921-3dc00abc87d9.csv");
3. 你可以嘗試放多個sub
##>



class moSolution{
    [String] $sub
    [String] $path
    [Array]$result
    [Object]$tempPublic
    [Array]$allPublicIp
    [Array]$allNic
    
    formatPublic(){
        foreach($publicIp in $this.allPublicIp){
            $configId = $publicIp.IpConfiguration.Id
            $publicipId = $publicIp.Id
            $IpAddress = $publicIp.IpAddress
            $PublicIpAllocationMethod = $publicIp.PublicIpAllocationMethod
            $this.tempPublic[$configId] = @{
                "publicipId"=$publicipId
                "IpAddress"=$IpAddress
                "PublicIpAllocationMethod"=$PublicIpAllocationMethod
            }


        }
    
    }
    exportToCSV(){
        $this.result | ForEach {
            [PSCustomObject]@{
                vmid = $_.vmid
                nicid = $_.nicid
                configid = $_.configid
                PrivateIpAddress = $_.PrivateIpAddress
                PrivateIpAllocationMethod = $_.PrivateIpAllocationMethod
                PublicIpAddress = $_.PublicIpAddress
                publicipId = $_.publicipId
                PublicIpAllocationMethod = $_.PublicIpAllocationMethod
            }
    
        } | Export-Csv $this.path -NoTypeInformation
        
    }
    execute(){
        $this.formatPublic();
        foreach($nic in $this.allNic){
    
            $nicid = $nic.Id
            $vmid = $nic.VirtualMachine.Id
            
            $ipconfigs = $nic.IpConfigurations
            foreach($config in $ipconfigs){
                $configId = $config.Id
                $configId
                $PrivateIpAddress = $config.PrivateIpAddress
                $PrivateIpAllocationMethod = $config.PrivateIpAllocationMethod
                $r = @{
                    "vmid"=$vmid
                    "nicid"=$nicid
                    "configid"=$configId
                    "PrivateIpAddress"=$PrivateIpAddress
                    "PrivateIpAllocationMethod"=$PrivateIpAllocationMethod
                    "PublicIpAddress"=$this.tempPublic[$configId].IpAddress
                    "publicipId"=$this.tempPublic[$configId].publicipId
                    "PublicIpAllocationMethod"=$this.tempPublic[$configId].publicipId
           
                }
                $this.result+=$r

            }


        }
    }
    selectSub(){
        Select-AzureRmSubscription -subscriptionid $this.sub
    }
    moSolution([String]$sub,[String]$path){
        
        $this.sub = $sub
        $this.selectSub()
        $this.path = $path
        $this.result = @()
        $this.tempPublic = @{}
        $this.allPublicIp = Get-AzureRmPublicIpAddress;
        $this.allNic = Get-AzureRmNetworkInterface;
        $this.execute();
        $this.exportToCSV();
    }
}

<###
範例
$mo0 = [moSolution]::new([String] "a4fdde52-f13a-412c-a921-3dc00abc87d9",[String] "C:\temp\a4fdde52-f13a-412c-a921-3dc00abc87d9.csv");
$mo1 = [moSolution]::new([String] "dc3770d4-ba09-48bd-868f-1f2bd295a66b",[String] "C:\temp\dc3770d4-ba09-48bd-868f-1f2bd295a66b.csv");

###>

