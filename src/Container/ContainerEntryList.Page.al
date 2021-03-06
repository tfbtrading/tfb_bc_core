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
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies no. of container entry';

                }
                field("Shipper"; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Tooltip = 'Specifies vendor for container';
                }


                field("Order Reference"; Rec."Order Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Lookup = true;
                    Tooltip = 'Specifies purchase order reference';
                }
                field("Vendor Reference"; Rec."Vendor Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    DrillDown = false;
                    Tooltip = 'Specifies vendor reference';
                }
                field("Container No."; Rec."Container No.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Tooltip = 'Specifies container no';

                }
                field("LinesDesc"; LineSummary)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the lines on the order';
                    MultiLine = false;
                    Editable = false;
                    Caption = 'Lines';
                }
                field("Quarantine Reference"; Rec."Quarantine Reference")
                {
                    ApplicationArea = All;
                    Editable = True;
                    Tooltip = 'Specifies quarantine reference';
                }
                field("Shipping Line"; Rec."Shipping Line")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Tooltip = 'Specifies shipping line';
                }

                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Tooltip = 'Specifies status of container';
                }
                field("Est. Departure Date"; Rec."Est. Departure Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Tooltip = 'Specifies est. date container leaves port';
                }
                field("Est. Arrival Date"; Rec."Est. Arrival Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies est. date container arrives';
                    Visible = false;
                }
                field("Est. Clear Date"; Rec."Est. Clear Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies est. date container is available';
                }
                field("% Sold"; _PercReserved)
                {
                    ApplicationArea = All;
                    Caption = '% Sold';
                    Editable = false;
                    ToolTip = 'Specifies the percentage of container contents sold';
                    AutoFormatType = 10;
                    AutoFormatExpression = '<precision, 1:1><standard format,0>%';
                }
                field("Inspection Req."; Rec."Inspection Req.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if inspection is required';
                }
                field("Fumigation Req."; Rec."Fumigation Req.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if fumigation is required';
                }
                field("TFB Unpack Attach."; Rec."Unpack Worksheet Attach." > 0)
                {
                    Caption = 'Unpack Worksheet Attached?';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Show whether unpack report attached';
                }

            }
        }
        area(Factboxes)
        {

            systempart(notes; Notes)
            {
                ApplicationArea = All;
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

        If rec.Type = rec.type::PurchaseOrder then
            if rec."Qty. On Purch. Rcpt" > 0 then
                ContainerCU.PopulateReceiptLines(rec, TempContainerContents)
            else
                ContainerCU.PopulateOrderOrderLines(Rec, TempContainerContents);



        TempContainerContents.CalcSums(Quantity, "Qty Sold (Base)");
        _QtyOnOrder := TempContainerContents.Quantity;
        _QtyReserved := TempContainerContents."Qty Sold (Base)";
        _PercReserved := (_QtyReserved / _QtyOnOrder);
        LineSummary := GetOrderLines();
    end;


    Local Procedure GetOrderLines(): Text

    var

        LineBuilder: TextBuilder;

    begin

        If TempContainerContents.Findset(false, false) then
            repeat

                LineBuilder.AppendLine(StrSubstNo('%1 (%2) - %3', TempContainerContents."Item Description", TempContainerContents."Item Code", TempContainerContents.Quantity));

            until TempContainerContents.Next() = 0;
        exit(LineBuilder.ToText());
    end;


    var
        TempContainerContents: Record "TFB ContainerContents" temporary;
        ContainerCU: Codeunit "TFB Container Mgmt";
        [InDataSet]
        _PercReserved, _QtyOnOrder, _QtyReserved : Decimal;
        LineSummary: Text;

}