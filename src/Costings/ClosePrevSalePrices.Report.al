report 50100 "TFB Close Prev. Sale Prices"
{

    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;
    Caption = 'Close Out Last Used Price';

    dataset
    {
        dataitem("Sales Price"; "Sales Price")
        {


            trigger OnPreDataItem()

            begin
                SetAscending("Starting Date", false);

                Window.Open(Text001Msg);
                SetRange("Starting Date", LastUpdatedDate);

            end;

            trigger OnAfterGetRecord()

            var
                PrevSalesPrice: Record "Sales Price";
                DteFormula: DateFormula;

            begin

                PrevSalesPrice.SetRange("Item No.", "Item No.");
                PrevSalesPrice.SetRange("Sales Code", "Sales Code");
                PrevSalesPrice.SetRange("Sales Type", "Sales Type");
                PrevSalesPrice.SetFilter("Starting Date", StrSubstNo('< %1', "Starting Date"));
                PrevSalesPrice.SetFilter("Ending Date", '');
                PrevSalesPrice.SetRange("Unit of Measure Code", "Unit of Measure Code");
                PrevSalesPrice.SetRange("Currency Code", "Currency Code");
                PrevSalesPrice.SetRange("Minimum Quantity", "Minimum Quantity");

                If PrevSalesPrice.FindFirst() then begin
                    Evaluate(DteFormula, '-1D');
                    PrevSalesPrice."Ending Date" := CalcDate(DteFormula, "Starting Date");
                    Window.Update(1, STRSUBSTNO('%1 %2', "Item No.", "Sales Code"));
                end;
            end;

            trigger OnPostDataItem()

            begin


                Window.Close();

            end;

        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(LastUpdatedDateReq; LastUpdatedDate)
                    {
                        Caption = 'Last Updated Date';
                        ApplicationArea = All;
                        ToolTip = 'Last date updated';

                    }
                }
            }
        }


    }

    var
        LastUpdatedDate: Date;

        Text001Msg: Label 'Updating prices:\#1############################Msg', comment = '%1 = item';

        Window: Dialog;
}