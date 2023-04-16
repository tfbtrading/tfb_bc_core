page 50211 "TFB Container Entry List"
{
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "TFB Container Entry";
    SourceTableView = sorting("Est. Arrival Date");
    Editable = true;
    ModifyAllowed = true;

    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = true;
    CardPageId = "TFB Container Entry";
    Caption = 'Inbound Shipments';
    DataCaptionFields = "Vendor Name", "Container No.", Status;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies no. of container entry';

                }
                field("Shipper"; Rec."Vendor No.")
                {
                    Editable = false;
                    Tooltip = 'Specifies vendor for container';
                }


                field("Order Reference"; Rec."Order Reference")
                {
                    Editable = false;
                    Lookup = true;
                    Tooltip = 'Specifies purchase order reference';
                }
                field("Vendor Reference"; Rec."Vendor Reference")
                {
                    Editable = false;
                    DrillDown = false;
                    Tooltip = 'Specifies vendor reference';
                }
                field("Container No."; Rec."Container No.")
                {
                    Editable = true;
                    Tooltip = 'Specifies container no';

                }
                field("LinesDesc"; LineSummary)
                {
                    ToolTip = 'Specifies the lines on the order';
                    MultiLine = false;
                    Editable = false;
                    Caption = 'Lines';
                }
                field("Quarantine Reference"; Rec."Quarantine Reference")
                {
                    Editable = true;
                    Tooltip = 'Specifies quarantine reference';
                }
                field("Shipping Line"; Rec."Shipping Line")
                {
                    Editable = true;
                    Tooltip = 'Specifies shipping line';
                }

                field("Status"; Rec."Status")
                {
                    Editable = true;
                    Tooltip = 'Specifies status of container';
                    Style = Attention;
                    StyleExpr = StatusAttention;
                }
                field(DestLocation; _location)
                {
                    Editable = false;
                    ToolTip = 'Specifies the current target location';
                    Caption = 'Intended Location';
                }
                field("Customer Direct"; Rec."Customer Direct")
                {
                    Editable = true;
                    ToolTip = 'Specifies whether the container is directly for a customer';
                }
                field("Est. Departure Date"; Rec."Est. Departure Date")
                {
                    Editable = true;
                    Tooltip = 'Specifies est. date container leaves port';
                }
                field("Est. Arrival Date"; Rec."Est. Arrival Date")
                {
                    Editable = true;
                    ToolTip = 'Specifies est. date container arrives';
                    Visible = false;
                }
                field("Est. Clear Date"; Rec."Est. Clear Date")
                {
                    Editable = true;
                    ToolTip = 'Specifies est. date container is available';
                }
                field("Inspection Date"; Rec."Inspection Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies inspection date for which container was booked';
                }
                field("% Sold"; _PercReserved)
                {
                    Caption = '% Sold';
                    Editable = false;
                    ToolTip = 'Specifies the percentage of container contents sold';
                    AutoFormatType = 10;
                    AutoFormatExpression = '<precision, 1:1><standard format,0>%';
                }
                field("Inspection Req."; Rec."Inspection Req.")
                {
                    Editable = false;
                    ToolTip = 'Specifies if inspection is required';
                }
                field("Fumigation Req."; Rec."Fumigation Req.")
                {
                    Editable = false;
                    ToolTip = 'Specifies if fumigation is required';
                }
                field("TFB Unpack Attach."; Rec."Unpack Worksheet Attach." > 0)
                {
                    Caption = 'Unpack Worksheet Attached?';
                    Editable = false;
                    ToolTip = 'Show whether unpack report attached';
                }

            }
        }
        area(Factboxes)
        {

            systempart(notes; Notes)
            {
            }
        }


    }


    actions
    {
        area(Processing)
        {
        }
    }


    views
    {


        view(Pending)
        {
            Caption = 'Containers to be Shipped';
            Filters = where(Status = filter(Planned | Booked));
            SharedLayout = true;
            OrderBy = ascending("Est. Departure Date");
        }
        view(Shipped)
        {
            Caption = 'Containers Shipped';
            Filters = where(Status = const(ShippedFromPort));
            SharedLayout = true;
            OrderBy = ascending("Est. Arrival Date");
        }
        view(Received)
        {
            Caption = 'Received or Completed';
            SharedLayout = true;
            Filters = where(Status = filter(Closed | PendingClearance));
            OrderBy = ascending("Est. Warehouse");
        }


    }

    trigger OnAfterGetRecord()

    begin
        Clear(TempContainerContents);
        Clear(_PercReserved);
        Clear(_QtyOnOrder);
        Clear(_QtyReserved);
        Rec.CalcFields("Qty. On Purch. Rcpt");

        if rec.Type = rec.type::PurchaseOrder then
            if rec."Qty. On Purch. Rcpt" > 0 then
                ContainerCU.PopulateReceiptLines(rec, TempContainerContents)
            else
                ContainerCU.PopulateOrderOrderLines(Rec, TempContainerContents);

        _location := ContainerCU.GetWarehouseLocation(Rec).Code;

        TempContainerContents.CalcSums(Quantity, "Qty Sold (Base)");
        _QtyOnOrder := TempContainerContents.Quantity;
        _QtyReserved := TempContainerContents."Qty Sold (Base)";
        _PercReserved := (_QtyReserved / _QtyOnOrder);
        LineSummary := GetOrderLines();
        StatusAttention := SetStatusStyle();
    end;


    local procedure GetOrderLines(): Text

    var

        LineBuilder: TextBuilder;

    begin

        if TempContainerContents.Findset(false) then
            repeat

                LineBuilder.AppendLine(StrSubstNo('%1 (%2) - %3', TempContainerContents."Item Description", TempContainerContents."Item Code", TempContainerContents.Quantity));

            until TempContainerContents.Next() = 0;
        exit(LineBuilder.ToText());
    end;

    local procedure SetStatusStyle(): Boolean
    begin

        case Rec.Status of
            Rec.Status::PendingClearance:
                if (Rec."Inspection Req." = true) and (Rec."Inspection Date" = 0D) then
                    StatusAttention := true
                else
                    StatusAttention := false;

            Rec.Status::PendingTreatment:
                if (Rec."Fumigation Req." = true) and (Rec."Fumigation Date" = 0D) then
                    StatusAttention := true
                else
                    StatusAttention := false;
        end;


    end;


    var
        TempContainerContents: Record "TFB ContainerContents" temporary;
        ContainerCU: Codeunit "TFB Container Mgmt";

        _PercReserved, _QtyOnOrder, _QtyReserved : Decimal;
        LineSummary: Text;
        _location: code[20];
        StatusAttention: Boolean;

}