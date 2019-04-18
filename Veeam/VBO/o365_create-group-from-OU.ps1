$OU="OU=EMEA,OU=Utenti,DC=npo-torino,DC=local"
$ShadowGroup="CN=DL-EMEA-ALL,OU=DistributionList,OU=Gruppi,OU=Utenti,DC=npo-torino,DC=local"
#Get-ADGroupMember –Identity $ShadowGroup | Where-Object {$_.distinguishedName –NotMatch $OU} | ForEach-Object {Remove-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup –Confirm:$false}
Get-ADGroupMember –Identity $ShadowGroup | ForEach-Object {Remove-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup –Confirm:$false}
Get-ADUser –SearchBase $OU –LDAPFilter "(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" | ForEach-Object {Add-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup}

$OU="OU=Consultant,OU=EMEA,OU=Utenti,DC=npo-torino,DC=local"
$ShadowGroup="CN=DL-EMEA-CONSULTANT,OU=DistributionList,OU=Gruppi,OU=Utenti,DC=npo-torino,DC=local"
Get-ADGroupMember –Identity $ShadowGroup  | ForEach-Object {Remove-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup –Confirm:$false}
Get-ADUser –SearchBase $OU –LDAPFilter "(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" | ForEach-Object {Add-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup}

$OU="OU=Employee,OU=EMEA,OU=Utenti,DC=npo-torino,DC=local"
$ShadowGroup="CN=DL-EMEA-EMPLOYEE,OU=DistributionList,OU=Gruppi,OU=Utenti,DC=npo-torino,DC=local"
Get-ADGroupMember –Identity $ShadowGroup  | ForEach-Object {Remove-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup –Confirm:$false}
Get-ADUser –SearchBase $OU –LDAPFilter "(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" | ForEach-Object {Add-ADPrincipalGroupMembership –Identity $_ –MemberOf $ShadowGroup}