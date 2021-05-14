page 50143 "TFB Sample Request Subform"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "TFB Sample Request Line";


    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;



                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;

                    ToolTip = 'Specifies the item number';

                    trigger OnValidate()
                    begin


                        CurrPage.Update();
                    end;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description of item being sampled';
                }



                field("Use Inventory"; Rec."Use Inventory")
                {
                    ApplicationArea = All;
                    Caption = 'Full Inventory Unit';
                    Enabled = Rec."No." <> '';
                }


                field("Customer Sample Size"; Rec."Customer Sample Size")
                {
                    ApplicationArea = All;
                    Enabled = (Rec."No." <> '');
                    Width = 10;
                    ToolTip = 'Specifies the size of sample in kilograms requested by customer';
                }

                field("Sourced From"; Rec."Sourced From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies where the sample is retrieved from';
                }
                field("Source Sample Size"; Rec."Source Sample Size")

                {
                    ApplicationArea = All;
                    Width = 10;
                    Enabled = (Rec."No." <> '') and ((Rec."Sourced From" = Rec."Sourced From"::Warehouse) or (Rec."Sourced From" = Rec."Sourced From"::Warehouse));
                    ToolTip = 'Specifies the size of sample in kilograms requested from source';
                }

                field("Line Status"; Rec."Line Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies status of retrieving this specific sample';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
        SampleRequestSize: Record "TFB Sample Request Size";
}