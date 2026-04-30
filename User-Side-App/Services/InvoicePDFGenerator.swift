//  InvoicePDFGenerator.swift
//  User-Side-App
//  Generates a premium Apple-style PDF invoice for orders.

import SwiftUI
import PDFKit

@MainActor
struct InvoicePDFGenerator {

    /// Generates a PDF file URL for the given order
    static func generateInvoice(for order: Order, userName: String) -> URL? {
        let renderer = ImageRenderer(content: InvoiceView(order: order, userName: userName))

        // Use a standard A4 size or similar
        let pageWidth: CGFloat = 595.28 // A4 width in points
        let pageHeight: CGFloat = 841.89 // A4 height in points

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Invoice-\(order.orderNumber).pdf")

        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

            guard let pdfContext = CGContext(tempURL as CFURL, mediaBox: &box, nil) else { return }

            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }

        return tempURL
    }
}

// MARK: - Invoice View (for rendering)

struct InvoiceView: View {
    let order: Order
    let userName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("DIOR")
                        .font(.system(size: 40, weight: .black))
                        .tracking(10)
                    Text("Official Receipt")
                        .font(.headline)
                        .foregroundStyle(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("INVOICE")
                        .font(.title).fontWeight(.bold)
                    Text("#\(order.orderNumber)")
                        .font(.subheadline).foregroundStyle(.gray)
                    Text(order.date.formatted(date: .long, time: .shortened))
                        .font(.caption).foregroundStyle(.gray)
                }
            }

            Divider()

            // Customer & Store Info
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("BILLED TO")
                        .font(.caption).fontWeight(.bold).foregroundStyle(.gray)
                    Text(userName)
                        .font(.headline)
                    Text("Standard Shipping")
                        .font(.subheadline).foregroundStyle(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("SOLD BY")
                        .font(.caption).fontWeight(.bold).foregroundStyle(.gray)
                    Text("Christian Dior Couture")
                        .font(.headline)
                    Text("Global Flagship Store\nParis, France")
                        .font(.subheadline).foregroundStyle(.gray)
                        .multilineTextAlignment(.trailing)
                }
            }

            // Table Header
            HStack {
                Text("DESCRIPTION").frame(maxWidth: .infinity, alignment: .leading)
                Text("QTY").frame(width: 50, alignment: .center)
                Text("PRICE").frame(width: 100, alignment: .trailing)
                Text("TOTAL").frame(width: 100, alignment: .trailing)
            }
            .font(.caption).fontWeight(.bold).foregroundStyle(.gray)
            .padding(.top, 20)

            Divider()

            // Items
            ForEach(order.items) { item in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.product.name)
                            .font(.subheadline).fontWeight(.bold)
                        if let variant = item.variant {
                            Text(variant)
                                .font(.caption).foregroundStyle(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text("\(item.quantity)")
                        .font(.subheadline)
                        .frame(width: 50, alignment: .center)

                    Text(item.priceAtPurchase.formattedPrice)
                        .font(.subheadline)
                        .frame(width: 100, alignment: .trailing)

                    Text((item.priceAtPurchase * Double(item.quantity)).formattedPrice)
                        .font(.subheadline).fontWeight(.bold)
                        .frame(width: 100, alignment: .trailing)
                }
            }

            Spacer()

            // Summary
            VStack(spacing: 12) {
                summaryRow(label: "Subtotal", value: order.subtotal.formattedPrice)
                if order.discount > 0 {
                    summaryRow(label: "Discount", value: "-\(order.discount.formattedPrice)")
                }
                summaryRow(label: "Taxes (18%)", value: order.taxes.formattedPrice)
                summaryRow(label: "Shipping", value: order.deliveryFee == 0 ? "FREE" : order.deliveryFee.formattedPrice)

                Divider()

                HStack {
                    Text("TOTAL")
                        .font(.headline).fontWeight(.bold)
                    Spacer()
                    Text(order.finalTotal.formattedPrice)
                        .font(.title2).fontWeight(.black)
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: 300)
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Footer
            VStack(spacing: 8) {
                Text("Thank you for your purchase.")
                    .font(.headline)
                Text("For support, please contact team5rsms@gmail.com")
                    .font(.caption).foregroundStyle(.gray)
                Text("This is a computer-generated document and does not require a signature.")
                    .font(.system(size: 8)).foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        }
        .padding(40)
        .frame(width: 595.28, height: 841.89) // A4 size
        .background(.white)
        .preferredColorScheme(.light) // Always light for PDF
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline).foregroundStyle(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}
