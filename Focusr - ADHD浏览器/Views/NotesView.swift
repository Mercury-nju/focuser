//
//  NotesView.swift
//  Focusr - ADHD浏览器
//

import SwiftUI

struct NotesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddNote = false
    @State private var newNoteContent = ""
    
    private var dataStore: DataStore { DataStore.shared }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataStore.notes.isEmpty {
                    EmptyStateView(
                        icon: "note.text",
                        title: "暂无笔记",
                        subtitle: "点击左上角添加笔记"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(dataStore.notes) { note in
                                NoteCard(note: note) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        dataStore.deleteNote(note)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color(white: 0.96))
            .navigationTitle("笔记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showAddNote = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color(white: 0.45))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("完成")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color(white: 0.45))
                    }
                }
            }
            .alert("添加笔记", isPresented: $showAddNote) {
                TextField("输入笔记内容", text: $newNoteContent, axis: .vertical)
                Button("取消", role: .cancel) { newNoteContent = "" }
                Button("保存") {
                    if !newNoteContent.isEmpty {
                        let note = Note(content: newNoteContent)
                        dataStore.addNote(note)
                        newNoteContent = ""
                    }
                }
            }
        }
    }
}

// MARK: - Note Card
struct NoteCard: View {
    let note: Note
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 内容
            Text(note.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(Color(white: 0.25))
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 底部信息
            HStack {
                if let url = note.sourceURL {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                        Text(url.host ?? "")
                            .font(.system(size: 11, weight: .regular))
                    }
                    .foregroundColor(Color(white: 0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(white: 0.94))
                    )
                }
                
                Spacer()
                
                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(white: 0.6))
                
                // 删除按钮
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(white: 0.55))
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color(white: 0.94))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.8), lineWidth: 0.5)
        )
    }
}
