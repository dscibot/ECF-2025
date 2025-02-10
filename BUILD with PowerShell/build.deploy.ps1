# Configuration
$INSTANCE_ID = "instance ID"
$KEY_PATH = "ecf.pem"
$WAR_FILE = "target/*.war"
$REGION = "eu-west-3"
$TOMCAT_USER = "user"
$TOMCAT_PASSWORD = "password"
$TOMCAT_PORT = "8080"

# Vérification de la clé SSH
if (-not (Test-Path $KEY_PATH)) {
    Write-Host "Erreur : La cle SSH $KEY_PATH est introuvable."
    exit 1
}

# Compilation du projet Java en .war
Write-Host "Compilation du projet..."
mvn clean package
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Echec de la compilation."
    exit 1 
}

# Récupération de l'adresse IP publique de la VM AWS
Write-Host "Récupération de l'adresse IP..."
$IP = aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text --region $REGION
if (-not $IP -or $IP -eq "None") { 
    Write-Host "Impossible de récupérer l'IP."
    exit 1 
}

# Vérification du fichier WAR
Write-Host "Recherche du fichier WAR..."
$WAR_PATH = Get-ChildItem -Path $WAR_FILE | Select-Object -First 1 -ExpandProperty FullName
if (-not $WAR_PATH) {
    Write-Host "Erreur : Aucun fichier WAR trouvé dans $WAR_FILE"
    exit 1
}

Write-Host "Fichier WAR trouve : $WAR_PATH"

# Transfert du fichier WAR sur la VM AWS
Write-Host "Transfert du fichier WAR vers la VM..."
scp -i "$KEY_PATH" -o StrictHostKeyChecking=no "$WAR_PATH" "admin@${IP}:/home/admin/app.war"
if ($LASTEXITCODE -ne 0) { 
    Write-Host "Echec du transfert du fichier."
    exit 1
}

# Déploiement sur Tomcat via l'API Manager
Write-Host "Déploiement sur Tomcat..."
$URL = "http://${IP}:${TOMCAT_PORT}/manager/text/deploy?path=/ecf&update=true"

Invoke-WebRequest -Uri $URL -Method Put -Credential (New-Object System.Management.Automation.PSCredential ($TOMCAT_USER, (ConvertTo-SecureString $TOMCAT_PASSWORD -AsPlainText -Force))) -InFile $WAR_PATH -ContentType "application/octet-stream" -UseBasicParsing

if ($LASTEXITCODE -ne 0) { 
    Write-Host "Echec du déploiement."
    exit 1 
}

# Affichage du lien d'accès
Write-Host "Deploiement reussi ! Application accessible sur : http://${IP}:${TOMCAT_PORT}/ecf"
