pageextension 50101 "TFB Location Card" extends "Location Card" //5703
{
    layout
    {
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