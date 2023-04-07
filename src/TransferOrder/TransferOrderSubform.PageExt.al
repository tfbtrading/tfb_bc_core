pageextension 50174 "TFB Transfer Order Subform" extends "Transfer Order Subform" //MyTargetPageId
{
    layout
    {
        addbefore("Qty. to Receive")
        {
            field("TFB Container Entry No."; Rec."TFB Container Entry No.")
            {
                caption = 'Container Entry';
                ApplicationArea = All;
                Enabled = true;
                ToolTip = 'Specifies container entry no.';
                Visible = Rec."TFB Container Entry No." <> '';
            }
            field("TFB Container No. LookUp"; Rec."TFB Container No. LookUp")
            {
                ApplicationArea = All;
                Tooltip = 'Specifies container number related to container entry';
                Visible = Rec."TFB Container Entry No." <> '';
                trigger OnDrillDown()

                var
                    Container: Record "TFB Container Entry";
                    ContainerPage: Page "TFB Container Entry";

                begin

                    if Container.Get(Rec."TFB Container Entry No.") then begin

                        ContainerPage.SetRecord(Container);
                        ContainerPage.Run();
                    end;

                end;
            }
        }

    }

    actions
    {
        addafter(Reserve)
        {
            action("Get container lines")
            {
                //Get Container from Header

                Image = Shipment;
                ApplicationArea = All;
                ToolTip = 'Get lines for container';

                trigger OnAction()

                var
                    Container: Record "TFB Container Entry";
                    Header: Record "Transfer Header";
                    ReceiptLine: Record "Purch. Rcpt. Line";
                    TransferLine: Record "Transfer Line";
                    PurchNo: Code[20];
                    LineNo: Integer;

                begin
                    if Header.Get(Rec."Document No.") then
                        if Container.Get(Header."TFB Container Entry No.") then begin

                            //Look for purchase receipt details
                            PurchNo := Container."Order Reference";

                            ReceiptLine.SetRange("Order No.", PurchNo);
                            ReceiptLine.SetRange(Type, ReceiptLine.Type::Item);
                            ReceiptLine.SetRange(Correction, false);
                            ReceiptLine.SetFilter("Quantity (Base)", '>0');


                            if ReceiptLine.FindSet() then
                                repeat
                                    LineNo := LineNo + 10000;
                                    //Insert new TransferLine details
                                    Clear(TransferLine);
                                    TransferLine.Init();
                                    TransferLine."Document No." := Header."No.";
                                    TransferLine.Validate("Item No.", ReceiptLine."No.");
                                    TransferLine.Validate("Unit of Measure", ReceiptLine."Unit of Measure");
                                    TransferLine.Validate(Quantity, ReceiptLine.Quantity);
                                    TransferLine.Validate("TFB Container Entry No.", Container."No.");
                                    TransferLine."Line No." := LineNo;
                                    TransferLine."TFB Container No." := Container."Container No.";
                                    TransferLine.Insert();

                                until ReceiptLine.Next() < 1;

                        end;

                end;
            }
        }
    }
}