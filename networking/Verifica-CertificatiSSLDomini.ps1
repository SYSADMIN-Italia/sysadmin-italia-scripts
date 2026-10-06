<#
.SYNOPSIS
    Verifica la data di scadenza del certificato SSL esposto da un elenco di domini.
#>
param(
    [Parameter(Mandatory=$true)]
    [string[]]$Domini,
    [int]$GiorniAvviso = 30,
    [string]$PercorsoCSV = "C:\Report\CertificatiSSLDomini.csv"
)

$risultati = foreach ($dominio in $Domini) {
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient($dominio, 443)
        $ssl = New-Object System.Net.Security.SslStream($tcp.GetStream())
        $ssl.AuthenticateAsClient($dominio)
        $certRaw = $ssl.RemoteCertificate
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certRaw)

        $giorniRimasti = ($cert.NotAfter - (Get-Date)).Days

        [PSCustomObject]@{
            Dominio       = $dominio
            Scadenza      = $cert.NotAfter.ToString("dd/MM/yyyy")
            GiorniRimasti = $giorniRimasti
            Allarme       = if ($giorniRimasti -le $GiorniAvviso) {"SI"} else {"NO"}
        }

        $ssl.Close(); $tcp.Close()
    }
    catch {
        [PSCustomObject]@{ Dominio = $dominio; Scadenza = "N/D"; GiorniRimasti = "N/D"; Allarme = "ERRORE: $_" }
    }
}

$risultati | Export-Csv -Path $PercorsoCSV -NoTypeInformation -Encoding UTF8 -Delimiter ";"
Write-Host "Controllati $($Domini.Count) domini." -ForegroundColor Green
