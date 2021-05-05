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

                field(Description; Description)
                {
                    ApplicationArea = All;
                }



                field(SampleSizeSel; SampleRequestSize.Description)
                {

                    ToolTip = 'Specifies the sample size to be sent';
                    Caption = 'Sample size';
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean

                    var
                        SampleSizes: Page "TFB Sample Request Sizes";


                    begin
                        SampleSizes.LookupMode(true);
                        SampleSizes.RunModal();
                    end;

                    trigger OnAfterLookup(Selected: RecordRef)


                    begin

                        Selected.SetTable(SampleRequestSize);
                        Rec."Sample Size SystemID" := SampleRequestSize.SystemId;
                        CurrPage.Update();
                    end;
                }

                field("Sourced From"; Rec."Sourced From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies where the sample is retrieved from';
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