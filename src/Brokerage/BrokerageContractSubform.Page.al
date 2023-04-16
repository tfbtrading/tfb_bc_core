page 50225 "TFB Brokerage Contract Subform"
{


    PageType = ListPart;
    Caption = 'Brokerage Contract Line';
    SourceTable = "TFB Brokerage Contract Line";
    RefreshOnActivate = true;
    ApplicationArea = All;



    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies item no. for line';
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies description for line';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ToolTip = 'Specifies quantity of items for line';
                }
                field("Qty. On Shipments"; Rec."Qty. On Shipments")
                {
                    DrillDown = false;
                    Editable = false;
                    Tooltip = 'Specifies qty from contract on shipment records';
                }

                field("Agreed Price"; Rec."Agreed Price")
                {
                    ToolTip = 'Specifies agreed price to be entered';
                }
                field("Pricing Unit Qty"; Rec."Pricing Unit Qty")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies pricing unit for agreed pricing';
                }
                field("Total MT"; Rec."Total MT")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies total aggregate MT of product on contract line';
                }
                field("Amount"; Rec."Amount")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies total value of product on contract line';
                }
                field("Brokerage Fee"; Rec."Brokerage Fee")
                {
                    BlankZero = true;
                    Editable = false;
                    ToolTip = 'Specifies brokerage fee calculated for contract line';
                }

            }

            group("Totals")
            {
                ShowCaption = false;



                group("Value")
                {

                    ShowCaption = false;

                    field(TotalValue; TotalValueOfLines)
                    {
                        Caption = 'Total value';
                        DecimalPlaces = 2;
                        AutoFormatExpression = '';
                        AutoFormatType = 1;
                        Editable = false;

                        ToolTip = 'Specifies total value of all lines';

                    }
                }
                group(Totals2)
                {
                    ShowCaption = false;

                    field(TotalBrokerage; TotalBrokerageOfLines)
                    {

                        DecimalPlaces = 2;
                        Editable = false;
                        ToolTip = 'Specifies total brokerage value for all lines';
                        Caption = 'Total brokerage';

                    }


                    field(TotalQuantity; TotalQuantityOfLines)
                    {
                        Caption = 'Total Quantity (MT)';
                        DecimalPlaces = 1;
                        Editable = false;
                        ToolTip = 'Specifies total metric tonne for all lines';
                    }



                }
            }


        }
    }

    actions
    {
        area(Processing)
        {



        }



    }



    trigger OnAfterGetCurrRecord()

    begin
        Rec.Validate(Quantity);
        CalculateBrokerageTotals();

    end;


    trigger OnAfterGetRecord()
    begin
        CalculateBrokerageTotals();
    end;

    /// <summary> 
    /// Set the value of total fields in the subform based on the current line items
    /// </summary>
    local procedure CalculateBrokerageTotals()
    var
        TotalLine: Record "TFB Brokerage Contract Line";


    begin

        if (Rec."Document No." <> '') then begin
            TotalLine.SetRange("Document No.", Rec."Document No.");

            TotalLine.CalcSums(Amount, "Total MT", "Brokerage Fee");

            TotalValueOfLines := TotalLine.Amount;
            TotalQuantityOfLines := TotalLine."Total MT";
            TotalBrokerageOfLines := TotalLine."Brokerage Fee";

        end;
    end;


    var
        TotalValueOfLines: Decimal;
        TotalBrokerageOfLines: Decimal;
        TotalQuantityOfLines: Decimal;


}