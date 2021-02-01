pageextension 50194 "TFB Task Card" extends "Task Card"
{
    layout
    {
        addafter("Opportunity Description")
        {
            field("TFB Trans. Description"; Rec."TFB Trans. Description")
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Transaction';
                Editable = false;
                Importance = Standard;
                DrillDown = true;
                AssistEdit = false;
                TableRelation = Opportunity;
                ToolTip = 'Specifies a description of the Opportunity that is related to the Task. The description is copied from the Campaign card.';

                trigger OnDrillDown()
                var
                    RecordRef: RecordRef;
                    Variant: Variant;
                    SalesHeader: Record "Sales Header";
                    PurchaseHeader: Record "Purchase Header";
                    SalesInvoice: Record "Sales Invoice Header";
                    PurchInvoice: Record "Purch. Inv. Header";
                begin
                    If not (Rec."TFB Trans. Record ID".TableNo > 0) then exit;
                    RecordRef.Get(Rec."TFB Trans. Record ID");
                    case recordRef.Number() of
                        Database::"Sales Header":
                            begin
                                RecordRef.SetTable(SalesHeader);
                                case SalesHeader."Document Type" of
                                    Enum::"Sales Document Type"::Quote:
                                        Page.Run(Page::"Sales Quote", SalesHeader);
                                    Enum::"Sales Document Type"::Order:
                                        Page.Run(Page::"Sales Order", SalesHeader);
                                end;
                            end;
                        Database::"Purchase Header":
                            begin
                                RecordRef.SetTable(PurchaseHeader);
                                case PurchaseHeader."Document Type" of
                                    Enum::"Purchase Document Type"::Order:
                                        Page.Run(Page::"Purchase Order", PurchaseHeader);
                                    Enum::"Purchase Document Type"::Invoice:
                                        Page.Run(Page::"Purchase Invoice", PurchaseHeader);
                                end;
                            end;
                        Database::"Sales Invoice Header":
                            begin
                                RecordRef.SetTable(SalesInvoice);
                                Page.Run(Page::"Posted Sales Invoice", SalesInvoice);
                            end;
                        Database::"Purch. Inv. Header":
                            begin
                                RecordRef.SetTable(PurchInvoice);
                                Page.Run(Page::"Posted Purchase Invoice", PurchInvoice);
                            end;

                    end;
                end;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }


}