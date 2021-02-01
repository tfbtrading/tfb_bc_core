pageextension 50107 "TFB Posted Purchase Receipt" extends "Posted Purchase Receipt" //136
{
    layout
    {

        modify("Order No.")
        {
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


    }

    actions
    {
        addlast(navigation)
        {
            action(Container)
            {
                ApplicationArea = All;
                Caption = 'Container';
                ToolTip = 'Opens up the related container for the purchase receipt';
                Visible = ContainerEntryNo <> '';

                trigger OnAction()
                begin

                    PurchCU.OpenRelatedContainer(ContainerEntryNo);

                end;
            }
        }

    }

    var
        PurchCU: CodeUnit "TFB Purch. Rcpt. Mgmt";
        ContainerEntryNo: Code[20];

    trigger OnAfterGetRecord()

    begin
        ContainerEntryNo := PurchCU.GetRelatedContainerEntry(Rec."No.");


    end;
}