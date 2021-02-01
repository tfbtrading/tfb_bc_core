query 50103 "TFB Interaction PowerBI"
{
    QueryType = API;
 
    EntitySetName = 'TFBPowerBIInteractions';
    EntityName = 'TFBPowerBIInteraction';
    APIPublisher = 'TFB';
    APIGroup = 'PowerBI';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Interaction_Log_Entry;"Interaction Log Entry")
        {
            
            column(AttachmentNo; "Attachment No.")
            {
            }
            column(AttemptFailed; "Attempt Failed")
            {
            }
            column(CampaignEntryNo; "Campaign Entry No.")
            {
            }
            column(CampaignNo; "Campaign No.")
            {
            }
            column(CampaignResponse; "Campaign Response")
            {
            }
            column(CampaignTarget; "Campaign Target")
            {
            }
            column(Canceled; Canceled)
            {
            }
            column(Comment; Comment)
            {
            }
            column(ContactAltAddressCode; "Contact Alt. Address Code")
            {
            }
            column(ContactCompanyName; "Contact Company Name")
            {
            }
            column(ContactCompanyNo; "Contact Company No.")
            {
            }
            column(ContactName; "Contact Name")
            {
            }
            column(ContactNo; "Contact No.")
            {
            }
            column(ContactVia; "Contact Via")
            {
            }
            column(CorrespondenceType; "Correspondence Type")
            {
            }
            column(CostLCY; "Cost (LCY)")
            {
            }
            column(Date; Date)
            {
            }
            column(DeliveryStatus; "Delivery Status")
            {
            }
            column(Description; Description)
            {
            }
            column(DocNoOccurrence; "Doc. No. Occurrence")
            {
            }
            column(DocumentNo; "Document No.")
            {
            }
            column(DocumentType; "Document Type")
            {
            }
            column(DurationMin; "Duration (Min.)")
            {
            }
            column(EMailLogged; "E-Mail Logged")
            {
            }
            column(EntryNo; "Entry No.")
            {
            }
            column(Evaluation; Evaluation)
            {
            }
            column(InformationFlow; "Information Flow")
            {
            }
            column(InitiatedBy; "Initiated By")
            {
            }
            column(InteractionGroupCode; "Interaction Group Code")
            {
            }
            column(InteractionLanguageCode; "Interaction Language Code")
            {
            }
            column(InteractionTemplateCode; "Interaction Template Code")
            {
            }
            column(LoggedSegmentEntryNo; "Logged Segment Entry No.")
            {
            }
            column(OpportunityNo; "Opportunity No.")
            {
            }
            column(Postponed; Postponed)
            {
            }
            column(SalespersonCode; "Salesperson Code")
            {
            }
            column(SegmentNo; "Segment No.")
            {
            }
            column(SendWordDocsasAttmt; "Send Word Docs. as Attmt.")
            {
            }
            column(Subject; Subject)
            {
            }
            column(SystemCreatedAt; SystemCreatedAt)
            {
            }
            column(SystemCreatedBy; SystemCreatedBy)
            {
            }
            column(SystemId; SystemId)
            {
            }
            column(SystemModifiedAt; SystemModifiedAt)
            {
            }
            column(SystemModifiedBy; SystemModifiedBy)
            {
            }
            column(TimeofInteraction; "Time of Interaction")
            {
            }
            column(TodoNo; "To-do No.")
            {
            }
            column(UserID; "User ID")
            {
            }
            column(VersionNo; "Version No.")
            {
            }
        }
    }

 
}