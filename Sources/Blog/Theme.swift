//
//  Theme.swift
//
//  Created by Piero Mattos on 20/05/20.
//

import Foundation
import Plot
import Publish

public extension Theme {
    static var blog: Self {
        Theme(
            htmlFactory: BlogHTMLFactory(),
            resourcePaths: ["Resources/styles/styles.css"]
        )
    }
}

private struct BlogHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1("Latest posts"),
                    .postsList(
                        for: context.allItems(sortedBy: \.date, order: .descending),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body(
                .header(for: context, selectedSection: section.id),
                .wrapper(
                    .h1(.text(section.title)),
                    .postsList(for: section.items, on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                .header(for: context, selectedSection: item.sectionID),
                .wrapper(
                    .article(
                        .div(
                            .class("content"),
                            .contentBody(item.body)
                        )
                    ),
                    .span("Tagged with: "),
                    .tagList(for: item, on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(.contentBody(page.body)),
                .footer(for: context.site)
            )
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1("Browse all tags"),
                    .ul(
                        .class("all-tags"),
                        .forEach(page.tags.sorted()) { tag in
                            .li(
                                .class("tag"),
                                .a(
                                    .href(context.site.path(for: tag)),
                                    .text(tag.string)
                                )
                            )
                        }
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1(
                        "Tagged with ",
                        .span(.class("tag"), .text(page.tag.string))
                    ),
                    .a(
                        .class("browse-all"),
                        .text("Browse all tags"),
                        .href(context.site.tagListPath)
                    ),
                    .postsList(
                        for: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}

private extension Node where Context == HTML.BodyContext {
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }

    static func header<T: Website>(for context: PublishingContext<T>, selectedSection: T.SectionID?) -> Node {
        .header(
            .wrapper(
                .p(
                    .class("site-name"),
                    .a(.href("/"), .text(context.site.name))
                ),
                .p(
                    .text("I'm an iOS software engineer and gamer from Jundiaí, SP, Brazil.")
                ),
                .p(
                    .headerLink("GitHub", href: "https://www.github.com/pieromattos"),
                    .headerLink("Stack Overflow", href: "https://stackoverflow.com/users/6758510/piero-mattos"),
                    .headerLink("LinkedIn", href: "https://www.linkedin.com/in/pieromattos"),
                    .headerLink("Twitter", href: "https://www.twitter.com/piero_mattos"),
                    .headerLink("E-mail", href: "mailto:piero@pmattos.com")
                )
            ),
            .div(.class("header-ribbon"))
        )
    }

    static func postsList<T: Website>(for items: [Item<T>], on site: T) -> Node {
        return .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(
                    .article(
                        .h1(.a( .href(item.path), .text(item.title))),
                        .p(.class("post-date"), "\(formattedPostDate(item.date))"),
                        .p(.class("post-preview"), .text(item.description)),
                        .p(.class("post-callout"), .a(
                            .class("callout-anchor"),
                            .href(item.path),
                            .text("continue reading...")
                        ))
                    )
                )
            }
        )
    }

    static func tagList<T: Website>(for item: Item<T>, on site: T) -> Node {
        return .ul(.class("tag-list"), .forEach(item.tags) { tag in
            .li(.a(
                .class("tag-item"),
                .href(site.path(for: tag)),
                .text(tag.string)
                ))
            })
    }

    static func footer<T: Website>(for site: T) -> Node {
        return .footer(
            .p(
                .text("Written (mostly) in Swift. Generated using "),
                .headerLink("Publish", href: "https://github.com/johnsundell/publish")
            ),
            .p(
                .headerLink("RSS Feed", href: "/feed.rss")
            )
        )
    }

    static func headerLink(_ text: String, href: String) -> Node {
        .a(.class("header-link"), .text(text), .href(href), .target(.blank))
    }

    static func formattedPostDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }

    static func preview<T: Website>(for item: Item<T>) -> String {
        ""
    }
}
