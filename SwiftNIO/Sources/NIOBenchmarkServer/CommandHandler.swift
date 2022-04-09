//
//  CommandHandler.swift
//  NIOBenchmarkServer
//
//  Created by Josef Zoller on 09.04.22.
//

import NIO


final class CommandHandler: ChannelInboundHandler {
    typealias InboundIn = [Command?]
    typealias InboundOut = ByteBuffer
    
    
    private let store: Store
    
    init(store: Store) {
        self.store = store
    }
    
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let commands = self.unwrapInboundIn(data)
        
        Task {
            let result = await commands.asyncMap({ command -> Substring in
                if let command = command {
                    switch command {
                    case let .get(key):
                        if let value = await self.store.getValue(forKey: key) {
                            return value
                        } else {
                            return "not found"
                        }
                    case let .set(key, value):
                        if let value = await self.store.setValue(forKey: key, to: value) {
                            return value
                        } else {
                            return "not found"
                        }
                    case let .delete(key):
                        if let value = await self.store.deleteValue(forKey: key) {
                            return value
                        } else {
                            return "not found"
                        }
                    case .getCount:
                        return "\(await self.store.getCount)"
                    case .setCount:
                        return "\(await self.store.setCount)"
                    case .deleteCount:
                        return "\(await self.store.deleteCount)"
                    }
                } else {
                    return "invalid command"
                }
            }).joined(separator: "\n") + "\n"
            
            context.eventLoop.execute {
                let outBuffer = context.channel.allocator.buffer(string: result)
                
                context.writeAndFlush(self.wrapInboundOut(outBuffer), promise: nil)
            }
        }
    }
}