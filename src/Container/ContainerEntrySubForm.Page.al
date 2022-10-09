page 50216 "TFB Container Entry SubForm"
{
    PageType = ListPart;

    SourceTable = "TFB ContainerContents";
    SourceTableTemporary = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies item code';

                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies item description';
                }
                field("UnitOfMeasure"; Rec."UnitOfMeasure")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies unit of measure';

                }
                field("Qty"; Rec."Quantity")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies quantity in container';
                }
                field("Qty Reserved"; Rec."Qty Sold (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies quantity reserved by customers from this line';
                }


            }
        }
    }



    actions
    {
        area(Processing)
        {

            Action(DownloadCOA)

            {
                ApplicationArea = All;
                Image = Document;
           
                Tooltip = 'Download certificates of analysis for items in container';
                Caption = 'Download certificates of analysis';


                trigger OnAction()
                var
                    ContainerCU: Codeunit "TFB Container Mgmt";
                begin

                    ContainerCU.DownloadContainerCoA(Rec);

                end;
            }

        }

    }



    procedure InitTempTable(var ContainerEntry: Record "TFB Container Entry"): Boolean
    var

        ContainerMgmt: Codeunit "TFB Container Mgmt";

    begin
        Rec.DeleteAll();
        ContainerEntry.CalcFields("Qty. On Purch. Rcpt", "Qty. On Transfer Ship.", "Qty. On Transfer Rcpt", "Qty. On Transfer Order");

        If not ContainerEntry.IsEmpty() then
            case ContainerEntry.Type of


                ContainerEntry.Type::"PurchaseOrder":

                    If ContainerEntry."Qty. On Transfer Rcpt" > 0 then
                        ContainerMgmt.PopulateTransferLines(ContainerEntry, Rec)
                    else
                        if ContainerEntry."Qty. On Transfer Ship." > 0 then
                            ContainerMgmt.PopulateTransferLines(ContainerEntry, Rec)
                        else
                            if ContainerEntry."Qty. On Transfer Order" > 0 then
                                ContainerMgmt.PopulateTransferLines(ContainerEntry, Rec)
                            else
                                if ContainerENtry."Qty. On Purch. Rcpt" > 0 then
                                    ContainerMgmt.PopulateReceiptLines(ContainerEntry, Rec)
                                else
                                    ContainerMgmt.PopulateOrderOrderLines(ContainerEntry, Rec);


            end;
    end;

    procedure GetLineTypeStatus(): enum "TFB Container Status"

    begin

        Exit(ContainerStatus);

    end;





    var



        ContainerStatus: Enum "TFB Container Status";


}