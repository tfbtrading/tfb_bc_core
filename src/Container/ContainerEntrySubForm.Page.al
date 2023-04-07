page 50216 "TFB Container Entry SubForm"
{
    PageType = ListPart;

    SourceTable = "TFB ContainerContents";
    SourceTableTemporary = true;
    Editable = false;
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item Code"; Rec."Item Code")
                {
                    ToolTip = 'Specifies item code';

                }
                field("Item Description"; Rec."Item Description")
                {
                    Tooltip = 'Specifies item description';
                }
                field("UnitOfMeasure"; Rec."UnitOfMeasure")
                {
                    Tooltip = 'Specifies unit of measure';

                }
                field("Qty"; Rec."Quantity")
                {
                    Tooltip = 'Specifies quantity in container';
                }
                field("Qty Reserved"; Rec."Qty Sold (Base)")
                {
                    ToolTip = 'Specifies quantity reserved by customers from this line';
                }


            }
        }
    }



    actions
    {
        area(Processing)
        {

            action(DownloadCOA)

            {
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

        if not ContainerEntry.IsEmpty() then
            case ContainerEntry.Type of


                ContainerEntry.Type::"PurchaseOrder":

                    if ContainerEntry."Qty. On Transfer Rcpt" > 0 then
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

        exit(ContainerStatus);

    end;





    var



        ContainerStatus: Enum "TFB Container Status";


}