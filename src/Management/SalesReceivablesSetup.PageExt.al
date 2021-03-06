pageextension 50221 "TFB Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Order Nos.")
        {
            field("TFB Brokerage Contract Nos."; Rec."TFB Brokerage Contract Nos.")
            {
                ApplicationArea = All;
                LookupPageId = "No. Series";
                ToolTip = 'Specifies number series for brokerage contracts';
            }
            field("TFB Brokerage Shipment Nos."; Rec."TFB Brokerage Shipment Nos.")
            {
                ApplicationArea = All;
                LookupPageId = "No. Series";
                Tooltip = 'Specifies number series for brokerage shipments';
            }

        }

        addafter(General)
        {
            group(ContactLifecycle)
            {
                caption = 'Contact Lifecycle Defaults';
                visible = true;
                field("TFB Lead Status"; Rec."TFB Lead Status")
                {
                    ApplicationArea = All;
                    visible = true;
                    ToolTip = 'Specifies the value of the Lead Status field';
                }
                field("TFB Prospect Status - New"; Rec."TFB Prospect Status - New")
                {
                    ApplicatioNArea = All;
                    ToolTip = 'Specifies the value of the Prospect Status - New field';
                }
                field("TFB Prospect Status - Opp"; Rec."TFB Prospect Status - Opp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prospect Status - Opp field';
                }
                field("TFB Prospect Status - Quote"; Rec."TFB Prospect Status - Quote")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prospect Status - Quote field';
                }
                field("TFB Converted Status"; Rec."TFB Converted Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Converted Status field';
                }
            }
        }

        addafter("Default Quantity to Ship")
        {
            field("Brokerage Default %"; Rec."Brokerage Default %")
            {

                ApplicationArea = All;
                AutoFormatType = 10;
                AutoFormatExpression = '<precision, 1:2><standard format,0>%';
                Tooltip = 'Specifies brokerage default % for contracts';

            }
            field("TFB Brokerage Service Item"; Rec."TFB Brokerage Service Item")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies the service item to use for generating brokerage service invoices';
            }
        }
        addlast(General)
        {
            field("TFB Auto Shipment Notification"; Rec."TFB Auto Shipment Notification")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies if auto shipment notifications are generated';
            }
            group(AutoShipment)
            {
                ShowCaption = false;
                Visible = Rec."TFB Auto Shipment Notification";

                field("TFB ASN Def. Job Resp. Rec."; Rec."TFB ASN Def. Job Resp. Rec.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies job responsibility for additional people receiving notification';
                }
            }
            field("TFB Credit Tolerance"; Rec."TFB Credit Tolerance")
            {
                ApplicationArea = All;
                AutoFormatType = 1;
                Tooltip = 'Specifies the amount for credit tolerance before notices are issues';
            }
            field("TFB Price List Def. Job Resp."; Rec."TFB PL Def. Job Resp. Rec.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the job responsibility for a contact that will receive price lists automatically';
            }
            field("TFB Def. Customer Price Group"; Rec."TFB Def. Customer Price Group")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies a customer price group that is the default for new customers';
            }
            field("TFB Item Price Group"; Rec."TFB Item Price Group")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customer price group that will be used to populate item unit prices';
            }
        }
    }



}