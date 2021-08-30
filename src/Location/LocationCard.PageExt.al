pageextension 50101 "TFB Location Card" extends "Location Card" //5703
{
    layout
    {
        addafter("Address & Contact")
        {
            group("Shipping Agents")
            {
                Group("Local Deliveries")
                {
                    field("TFB Lcl Shipping Agent Code"; Rec."TFB Lcl Shipping Agent Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Shipping Agent';
                        ToolTip = 'Specifies the agent to be used for local deliveries';
                    }
                    field("TFB Lcl Agent Service Code"; Rec."TFB Lcl Agent Service Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Default Service Code';
                        ToolTip = 'Specifies the default service level for agent for local deliveries';
                    }

                }

                Group("Interstate Deliveries")
                {
                    field("TFB Insta Shipping Agent Code"; Rec."TFB Insta Shipping Agent Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Shipping Agent';
                        ToolTip = 'Specifies the agent to be used for interstate deliveries';
                    }
                    field("TFB Insta Agent Service Code"; Rec."TFB Insta Agent Service Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Default Service Code';
                        ToolTip = 'Specifies the default service level for agent for interstate deliveries';
                    }

                }
            }
        }
        addbefore("Use As In-Transit")
        {
            field("TFB Enabled"; Rec."TFB Enabled")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if location is current active for shipments and receipts';

            }
            field("TFB Location Type"; Rec."TFB Location Type")
            {
                Importance = Promoted;
                ApplicationArea = All;
                ToolTip = 'Specifies purpose of the location';

            }
        }
        addafter("Inbound Whse. Handling Time")
        {
            field("TFB Quarantine Location"; Rec."TFB Quarantine Location")
            {
                ToolTip = 'Specifies if location is a warehouse for handling imports';
                ApplicationArea = All;
            }
            group("AQIS Delay Defaults")
            {
                Caption = 'Quarantine Location Details';
                ShowCaption = true;
                Visible = Rec."TFB Quarantine Location";
                field("TFB AA No."; Rec."TFB AA No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the License No. for warehouse location';
                }
                field("TFB Fumigation Time Delay"; Rec."TFB Fumigation Time Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delay in days waiting for fumigation to occur';
                }
                field("TFB Inspection Time Delay"; Rec."TFB Inspection Time Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delay in days waiting for inspection to occur';
                }
                field("TFB X-Ray Time Delay"; Rec."TFB X-Ray Time Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delay in days waiting for x-ray to occur';
                }
                field("TFB Heat Treat. Time Delay"; Rec."TFB Heat Treat. Time Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies he delay in days waiting for heat treatment to occur';
                }
            }
        }
    }

    actions
    {

    }
}