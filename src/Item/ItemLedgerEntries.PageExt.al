pageextension 50272 "TFB Item Ledger Entries" extends "Item Ledger Entries" //38
{
    layout
    {
        addafter("Document No.")
        {
            field("TFB Order No."; OrderNo)
            {
                ApplicationArea = All;
                Caption = 'Order No';
                ToolTip = 'Specifies sales order number';
            }
            field("External Document No."; Rec."External Document No.")
            {
                ApplicationArea = All;
                Caption = 'Ext. Doc. No.';
                Tooltip = 'Specifies external document number';
            }
            field("Source No."; Rec."Source No.")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies source number';
            }
            field("TFB Source Desc."; SourceDesc)
            {
                ApplicationArea = All;
                Caption = 'Source Desc.';
                ToolTip = 'Specifies source description';
            }

        }

        addbefore("Lot No.")
        {
            field(TrafficLight; getLotTrafficLight())
            {
                ApplicationArea = All;
                Caption = 'Lot Status';
                ToolTip = 'Specifies whether a lot number is currently available for sale or not';
            }
        }
        modify("Order Type")
        {
            Visible = false;
        }
        modify("Entry No.")
        {
            Visible = false;
        }

        modify("Lot No.")
        {
            trigger OnDrillDown()

            begin
                ShowLotInfoIntelligently(Rec."Item No.", Rec."Variant Code", Rec."Lot No.");
            end;


        }
        addlast(Control1)
        {
            field("TFB No. Of Lot Images"; Rec."TFB No. Of Lot Images")
            {
                ApplicationArea = All;
                Caption = 'No. of Lot Images';
                Visible = false;
            }
        }


    }

    actions
    {
        addafter("Order &Tracking")
        {
            action("TFB Update Sales Line Dates")
            {
                ApplicationArea = All;
                Image = UpdateShipment;
                InFooterBar = true;
                Caption = 'Update sales shipment dates';
                Enabled = Rec."Document Type" = Rec."Document Type"::"Purchase Receipt";
                ToolTip = 'Will alter any pending orders reserved from item ledger entry to be available for delivery';

                trigger OnAction()

                var
                    SalesCU: CodeUnit "TFB Sales Mgmt";
                begin

                    If (Rec."Entry Type" = Rec."Entry Type"::Purchase) and (Rec."Remaining Quantity" > 0) then
                        SalesCU.AdjustSalesLinePlannedDateByItemRes(Rec);
                end;
            }
        }
        addlast("F&unctions")
        {
            action("TFB Get Lot Image Wizard")
            {
                ApplicationArea = All;
                Image = Picture;
                Caption = 'Get Lot Image Wizard';
                Enabled = true;
                ToolTip = 'Open lot image wizard';

                trigger OnAction()

                var
                    GetWizard: Page "TFB Lot Get Image Wizard";

                begin
                    GetWizard.InitFromItemLedger(Rec);
                    GetWizard.RunModal();

                end;
            }
            action("TFB Add Lot Image Wizard")
            {
                ApplicationArea = All;
                Image = Picture;
                Caption = 'Add Lot Image Wizard';
                Enabled = true;
                ToolTip = 'Add lot image wizard';

                trigger OnAction()

                var

                    AddWizard: Page "TFB Lot Add Image Wizard";

                begin


                    AddWizard.InitFromItemLedgerID(Rec.SystemId);
                    AddWizard.RunModal();
                end;
            }


        }
    }

    views
    {
        addlast
        {
            view(PendingLotImages)
            {
                Caption = 'Requiring Lot Image';
                Filters = where("Entry Type" = filter(Purchase | Transfer), Quantity = filter(> 0), Nonstock = const(false), "Drop Shipment" = const(false), "Lot No." = filter('<>'''''), "Document Type" = filter('<>Purchase Invoice'), Positive = const(true), "Location Code" = filter('EFFLOG'), "Posting Date" = filter('>today-60d'), "TFB No. Of Lot Images" = filter('=0'), "Remaining Quantity" = filter('>40'));
                OrderBy = ascending("Posting Date");
                SharedLayout = false;

                layout
                {
                    modify("Entry Type")
                    {
                        Visible = false;
                    }
                    modify("Document No.")
                    {
                        Visible = false;
                    }
                    modify("External Document No.")
                    {
                        Visible = false;
                    }
                    modify("Lot No.")
                    {
                        Visible = true;
                    }
                    modify("Global Dimension 1 Code")
                    {
                        Visible = false;
                    }
                    modify("Global Dimension 2 Code")
                    {
                        Visible = false;
                    }
                    modify("Invoiced Quantity")
                    {
                        Visible = false;
                    }
                    modify("Sales Amount (Actual)")
                    {
                        Visible = false;
                    }
                    modify("Cost Amount (Actual)")
                    {
                        Visible = false;
                    }
                    modify("Cost Amount (Non-Invtbl.)")
                    {
                        Visible = false;
                    }
                    moveafter("Item No."; "Lot No.", "TFB No. Of Lot Images")



                }
            }
        }
    }


    trigger OnAfterGetRecord()

    begin
        //Populate Item Ledger Details if Sales Shipment
        UpdateSalesShipmentDetails();

    end;

    local procedure GetLotTrafficLight(): text[6]

    var
        LotNoInformation: Record "Lot No. Information";

    begin
        If CheckValidAvailableEntry() then
            If LotNoInformation.Get(Rec."Item No.", Rec."Variant Code", Rec."Lot No.") then
                If Not LotNoInformation.Blocked then
                    Exit('✅')
                else
                    If LotNoInformation."TFB Date Available" <> 0D then
                        Exit('⛔')
                    else
                        Exit('❓')
            else
                Exit('🗋')
        else
            Exit('⚪');

    end;

    local procedure CheckValidAvailableEntry(): Boolean



    begin

        If IsValidDocumentType(Rec."Document Type") and (Rec."Remaining Quantity" > 0) then exit(true);
    end;




    /// <summary> 
    /// Figures out what lot information to show given a specific set of data 
    /// </summary>
    /// <param name="ItemNo">Parameter of type Code[20].</param>
    /// <param name="VariantCode">Parameter of type Code[20].</param>
    /// <param name="LotNo">Parameter of type Code[50].</param>
    local procedure ShowLotInfoIntelligently(ItemNo: Code[20]; VariantCode: Code[20]; LotNo: Code[50])

    var
        LotInfo: record "Lot No. Information";

    begin

        If LotInfo.Get(ItemNo, VariantCode, LotNo) then
            Page.Run(Page::"Lot No. Information Card", LotInfo);
    end;

    /// <summary> 
    /// Description for UpdateSalesShipmentDetails.
    /// </summary>
    /// <returns>Return variable "Boolean".</returns>
    local procedure UpdateSalesShipmentDetails(): Boolean

    var

    begin

        Clear(ShipmentRec);
        Clear(ReceiptRec);
        Clear(SourceDesc);
        Clear(OrderNo);

        case Rec."Document Type" of
            Rec."Document Type"::"Sales Shipment":

                If (Rec."Source Type" = Rec."Source Type"::Customer) and (Rec."Source No." <> '') then
                    If ShipmentRec.Get(Rec."Document No.") then begin
                        OrderNo := ShipmentRec."Order No.";
                        SourceDesc := ShipmentRec."Sell-to Customer Name";
                    end;

            Rec."Document Type"::"Purchase Receipt":

                if (Rec."Source Type" = Rec."Source Type"::Vendor) and (Rec."Source No." <> '') then
                    If ReceiptRec.Get(Rec."Document No.") then begin
                        OrderNo := ReceiptRec."Order No.";
                        SourceDesc := ReceiptRec."Buy-from Vendor Name";
                    end;

            Rec."Document Type"::"Sales Return Receipt":

                if (Rec."Source Type" = Rec."Source Type"::Customer) and (Rec."Source No." <> '') then
                    If ReturnRec.Get(Rec."Document No.") then begin
                        OrderNo := ReturnRec."Return Order No.";
                        SourceDesc := ReturnRec."Sell-to Customer Name";
                    end;
        end;

    end;

    local procedure IsValidDocumentType(DocumentType: Enum "Item Ledger Document Type"): Boolean
    begin
        case DocumentType of
            DocumentType::"Direct Transfer":
                exit(true);
            DocumentType::"Inventory Receipt":
                exit(true);
            DocumentType::"Purchase Receipt":
                exit(true);
            DocumentType::"Sales Return Receipt":
                exit(true);
            DocumentType::"Transfer Receipt":
                exit(true);
            else
                exit(false);
        end;
    end;

    var
        ShipmentRec: Record "Sales Shipment Header";
        ReceiptRec: Record "Purch. Rcpt. Header";

        ReturnRec: Record "Return Receipt Header";
        SourceDesc: Text[100];
        OrderNo: Text[100];

}