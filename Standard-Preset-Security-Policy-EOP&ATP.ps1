
#ATPBuiltInProtectionRule
New-SafeAttachmentPolicy -Name "Baseline | Standard Safe Attachment" -Action Block -Enable $true
New-SafeLinksPolicy -Name "Baseline | Standard Safe Links" -AllowClickThrough $true -DeliverMessageAfterScan $true -DisableUrlRewrite $true -ScanUrls $true -TrackClicks $true -EnableSafeLinksForEmail $true -EnableSafeLinksForOffice $true

#EOPProtectionPolicyRule
New-HostedContentFilterPolicy -Name "Baseline | Standard Hosted Content Filter" -BulkSpamAction MoveToJmf -BulkThreshold 6 -HighConfidencePhishAction Quarantine -HighConfidenceSpamQuarantineTag DefaultFullAccessWithNotificationPolicy -PhishQuarantineTag DefaultFullAccessWithNotificationPolicy -PhishSpamAction Quarantine -PhishZapEnabled $true -HighConfidencePhishQuarantineTag AdminOnlyAccessPolicy -BulkQuarantineTag DefaultFullAccessPolicy -InlineSafetyTipsEnabled $true -MarkAsSpamBulkMail On -SpamAction MoveToJmf -SpamQuarantineTag DefaultFullAccessPolicy -SpamZapEnabled $true 

New-AntiPhishPolicy -Name "Baseline | Standard Anti Phish" -AuthenticationFailAction MoveToJmf -DmarcQuarantineAction Quarantine -DmarcRejectAction Reject -EnableMailboxIntelligence $true -EnableMailboxIntelligenceProtection $true -EnableOrganizationDomainsProtection $true -EnableSimilarUsersSafetyTips $true -EnableSimilarDomainsSafetyTips $true -EnableSpoofIntelligence $true -EnableTargetedDomainsProtection $true -EnableTargetedUserProtection $true -EnableUnauthenticatedSender $true -EnableUnusualCharactersSafetyTips $true -EnableViaTag $true -HonorDmarcPolicy $true -ImpersonationProtectionState Automatic -MailboxIntelligenceProtectionAction MoveToJmf -MailboxIntelligenceQuarantineTag DefaultFullAccessPolicy -PhishThresholdLevel 2 -SpoofQuarantineTag DefaultFullAccessPolicy -TargetedDomainQuarantineTag DefaultFullAccessWithNotificationPolicy -TargetedUserQuarantineTag DefaultFullAccessWithNotificationPolicy 

New-MalwareFilterPolicy -Name "Baseline | Standard Malware Filter" -QuarantineTag AdminOnlyAccessPolicy -ZapEnabled $true 