page 50225 "TFB Brokerage Contract Subform"
{


    PageType = ListPart;
    SourceTable = "TFB Brokerage Contract Line";
    RefreshOnActivate = true;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies item no. for line';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies description for line';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies quantity of items for line';
                }
                field("Qty. On Shipments"; Rec."Qty. On Shipments")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Tooltip = 'Specifies qty from contract on shipment records';
                }

                field("Agreed Price"; Rec."Agreed Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies agreed price to be entered';
                }
                field("Pricing Unit Qty"; Rec."Pricing Unit Qty")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies pricing unit for agreed pricing';
                }
                field("Total MT"; Rec."Total MT")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies total aggregate MT of product on contract line';
                }
                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies total value of product on contract line';
                }
                field("Brokerage Fee"; Rec."Brokerage Fee")
                {
                    ApplicationArea = All;
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

                    Field(TotalValue; TotalValueOfLines)
                    {
                        Caption = 'Total value';
                        DecimalPlaces = 2;
                        ApplicationArea = All;
                        AutoFormatExpression = '';
                        AutoFormatType = 1;
                        Editable = false;

                        ToolTip = 'Specifies total value of all lines';

                    }
                }
                group(Totals2)
                {
                    ShowCaption = false;

                    Field(TotalBrokerage; TotalBrokerageOfLines)
                    {

                        DecimalPlaces = 2;
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies total brokerage value for all lines';
                        Caption = 'Total brokerage';

                    }


                    Field(TotalQuantity; TotalQuantityOfLines)
                    {
                        Caption = 'Total Quantity (MT)';
                        DecimalPlaces = 1;
                        ApplicationArea = All;
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
            action("Item")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                Image = Item;
                ToolTip = 'Opens item card for line item';
                Caption = 'Item';


                trigger OnAction()

                var
                    ItemRec: Record Item;
                    ItemPage: Page "Item Card";

                begin
                    ItemRec.Get(Rec."Item No.");
                    ItemPage.SetRecord(ItemRec);
                    ItemPage.Run();



                end;

            }


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

        If (Rec."Document No." <> '') then begin
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