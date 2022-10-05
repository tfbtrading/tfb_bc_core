page 50228 "TFB Brokerage Shipment Subform"
{


    PageType = ListPart;
    SourceTable = "TFB Brokerage Shipment Line";
    Caption = 'Lines';


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

                        If BrokerContractLines.FindSet() then
                            repeat
                                If FilterLiteral = '' then
                                    FilterLiteral := BrokerContractLines."Item No."
                                else
                                    FilterLiteral += '|' + BrokerContractLines."Item No."
                                until BrokerContractLines.Next() = 0;

                        Item.SetFilter(Item."No.", FilterLiteral);
                        If PAGE.RunModal(0, Item) = Action::LookupOK THEN begin
                            Text := Item."No.";
                            Exit(true);
                        end;
                    end;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies description for line item';
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies quantity for line item';
                    Visible = not UsingBulkers;

                    trigger OnValidate()

                    begin
                        CurrPage.Update(false);
                    end;

                }

                field(Bulkers; Rec.BulkerQuantity)
                {
                    ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies agreed price for line item. Automatically calculated.';

                    trigger OnValidate()

                    begin
                        CurrPage.Update(false);
                    end;
                }

                field("Total MT"; Rec."Total MT")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    DecimalPlaces = 1 : 2;
                    ToolTip = 'Specifies total metric tonne for each line item. Automatically calculated.';
                }
                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies total amount for line item. Automatically calculated';
                }
                field("Brokerage Fee"; Rec."Brokerage Fee")
                {
                    ApplicationArea = All;
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

        If BrokerageShipment.Get(Rec."Document No.") then
            Exit(BrokerageShipment.Bulkers);

    end;

}
