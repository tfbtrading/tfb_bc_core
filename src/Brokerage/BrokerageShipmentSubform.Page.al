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

                }

                field("Agreed Price"; Rec."Agreed Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies agreed price for line item. Automatically calculated.';
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
                ToolTip = 'Open item card for line item';


                trigger OnAction()

                var
                    ItemRec: Record Item;
                    ItemPage: Page "Item Card";

                begin
                    ItemRec.Get(Rec."Item No.");
                    ItemPage.Run();
                    ItemPage.GetRecord(ItemRec);

                end;

            }

        }

    }

    trigger OnAfterGetCurrRecord()

    begin
        Rec.Validate(Quantity);
    end;



}
