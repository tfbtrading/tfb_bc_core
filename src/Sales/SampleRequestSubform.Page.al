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

                field(SampleSizeSel; SampleRequestSize.Description)
                {

                    ToolTip = 'Specifies the sample size to be sent';
                    Caption = 'Sample size';
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean

                    var


                    begin
                        Page.RunModal(Page::"TFB Sample Request Sizes")
                    end;

                    trigger OnAfterLookup(Selected: RecordRef)


                    begin

                        Selected.SetTable(SampleRequestSize);

                        Rec."Sample Size SystemID" := SampleRequestSize.SystemId;

                    end;
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