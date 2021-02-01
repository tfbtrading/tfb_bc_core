pageextension 50220 "TFB Posted Purchase Receipts" extends "Posted Purchase Receipts" //145
{
    layout
    {
        addafter("No.")
        {
            field("TFBOrder No."; Rec."Order No.")
            {
                ApplicationArea = All;
                Visible = True;
                ToolTip = 'Specifies the order number receipt';

                trigger OnDrillDown()

                var
                    OpenOrder: Record "Purchase Header";
                    ArchiveOrder: Record "Purchase Header Archive";
                    OpenOrderPage: Page "Purchase Order";
                    ArchiveOrderPage: Page "Purchase Order Archive";

                begin

                    OpenOrder.SetRange("Document Type", OpenOrder."Document Type"::Order);
                    OpenOrder.SetRange("No.", Rec."Order No.");

                    If OpenOrder.FindFirst() then begin

                        OpenOrderPage.SetRecord(OpenOrder);
                        OpenOrderPage.Run();
                    end
                    else begin
                        ArchiveOrder.SetRange("Document Type"::Order);
                        ArchiveOrder.SetRange("No.", Rec."Order No.");

                        If ArchiveOrder.FindLast() then begin
                            ArchiveOrderPage.SetRecord(ArchiveOrder);
                            ArchiveOrderPage.Run();
                        end;

                    end;

                end;
            }

            field("Vendor Order No."; Rec."Vendor Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies vendors order number corresponding to our purchase';
                Visible = true;
            }



        }


    }


}