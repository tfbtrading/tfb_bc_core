query 50103 "TFB Interaction PowerBI"
{
    QueryType = API;

    EntitySetName = 'tfbPowerBIInteractions';
    EntityName = 'tfbPowerBIInteraction';
    APIPublisher = 'tfb';
    APIGroup = 'tfbPowerBI';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(interactionLogEntry; "Interaction Log Entry")
        {

            column(attachmentNo; "Attachment No.")
            {
            }
            column(attemptFailed; "Attempt Failed")
            {
            }
            column(campaignEntryNo; "Campaign Entry No.")
            {
            }
            column(campaignNo; "Campaign No.")
            {
            }
            column(campaignResponse; "Campaign Response")
            {
            }
            column(campaignTarget; "Campaign Target")
            {
            }
            column(canceled; Canceled)
            {
            }
            column(comment; Comment)
            {
            }
            column(contactAltAddressCode; "Contact Alt. Address Code")
            {
            }
            column(contactCompanyName; "Contact Company Name")
            {
            }
            column(contactCompanyNo; "Contact Company No.")
            {
            }
            column(contactName; "Contact Name")
            {
            }
            column(contactNo; "Contact No.")
            {
            }
            column(contactVia; "Contact Via")
            {
            }
            column(correspondenceType; "Correspondence Type")
            {
            }
            column(costLCY; "Cost (LCY)")
            {
            }
            column(dateStarted; Date)
            {
            }
            column(deliveryStatus; "Delivery Status")
            {
            }
            column(description; Description)
            {
            }
            column(docNoOccurrence; "Doc. No. Occurrence")
            {
            }
            column(documentNo; "Document No.")
            {
            }
            column(documentType; "Document Type")
            {
            }
            column(durationMin; "Duration (Min.)")
            {
            }
            column(eMailLogged; "E-Mail Logged")
            {
            }
            column(entryNo; "Entry No.")
            {
            }
            column(evaluation; Evaluation)
            {
            }
            column(informationFlow; "Information Flow")
            {
            }
            column(initiatedBy; "Initiated By")
            {
            }
            column(interactionGroupCode; "Interaction Group Code")
            {
            }
            column(interactionLanguageCode; "Interaction Language Code")
            {
            }
            column(interactionTemplateCode; "Interaction Template Code")
            {
            }
            column(loggedSegmentEntryNo; "Logged Segment Entry No.")
            {
            }
            column(opportunityNo; "Opportunity No.")
            {
            }
            column(postponed; Postponed)
            {
            }
            column(salespersonCode; "Salesperson Code")
            {
            }
            column(segmentNo; "Segment No.")
            {
            }
            column(sendWordDocsasAttmt; "Send Word Docs. as Attmt.")
            {
            }
            column(subject; Subject)
            {
            }
            column(systemCreatedAt; SystemCreatedAt)
            {
            }
            column(systemCreatedBy; SystemCreatedBy)
            {
            }
            column(systemId; SystemId)
            {
            }
            column(systemModifiedAt; SystemModifiedAt)
            {
            }
            column(systemModifiedBy; SystemModifiedBy)
            {
            }
            column(timeofInteraction; "Time of Interaction")
            {
            }
            column(todoNo; "To-do No.")
            {
            }
            column(userID; "User ID")
            {
            }
            column(versionNo; "Version No.")
            {
            }
        }
    }


}