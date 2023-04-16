page 50228 "TFB Brokerage Shipment Subform"
{


    PageType = ListPart;
    SourceTable = "TFB Brokerage Shipment Line";
    Caption = 'Lines';
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

                    trigger OnLookup(var Text: Text): Boolean

                    var
                        BrokerContractLines: record "TFB Brokerage Contract Line";
                        BrokerageShipment: record "TFB Brokerage Shipment";
                        Item: record Item;
                        FilterLiteral: Text;

                    begin
                        BrokerageShipment.Reset();
                        BrokerageShipment.get(Rec."Document No.");
                        BrokerContractLines.Reset();
                        BrokerContractLines.SetRange("Document No.", BrokerageShipment."Contract No.");

                        if BrokerContractLines.FindSet() then
                            repeat
                                if FilterLiteral = '' then
                                    FilterLiteral := BrokerContractLines."Item No."
                                else
                                    FilterLiteral += '|' + BrokerContractLines."Item No."
                                until BrokerContractLines.Next() = 0;

                        Item.SetFilter(Item."No.", FilterLiteral);
                        if PAGE.RunModal(0, Item) = Action::LookupOK then begin
                            Text := Item."No.";
                            exit(true);
                        end;
                    end;
                }
                field("Description"; Rec."Description")
                {
                    ToolTip = 'Specifies description for line item';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ToolTip = 'Specifies quantity for line item';
                    Visible = not UsingBulkers;



                }

                field(Bulkers; Rec.BulkerQuantity)
                {
                    ToolTip = 'Specifies quantity for line item';
                    Caption = 'Bulker Quantity';
                    Visible = UsingBulkers;

                    trigger OnValidate()

                    begin
                        CurrPage.Update(false);
                    end;

                }

                field("Agreed Price"; Rec."Agreed Price")
                {
                    ToolTip = 'Specifies agreed price for line item. Automatically calculated.';

                    trigger OnValidate()

                    begin
                        CurrPage.Update(false);
                    end;
                }

                field("Total MT"; Rec."Total MT")
                {
                    BlankZero = true;
                    DecimalPlaces = 1 : 2;
                    ToolTip = 'Specifies total metric tonne for each line item. Automatically calculated.';
                }
                field("Amount"; Rec."Amount")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies total amount for line item. Automatically calculated';
                }
                field("Brokerage Fee"; Rec."Brokerage Fee")
                {
                    BlankZero = true;
                    ToolTip = 'Specifies brokerage fee for line item. Automatically calculated';
                }

            }

        }

    }


    trigger OnAfterGetCurrRecord()

    begin
        Rec.Validate(Quantity);
    end;

    trigger OnAfterGetRecord()

    begin
        UsingBulkers := CheckIfBulkers();
    end;

    var
        UsingBulkers: Boolean;


    local procedure CheckIfBulkers(): Boolean

    var
        BrokerageShipment: Record "TFB Brokerage Shipment";

    begin

        if BrokerageShipment.Get(Rec."Document No.") then
            exit(BrokerageShipment.Bulkers);

    end;

}
