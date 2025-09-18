import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Room, RoomDocument } from './schemas/room.schema';
import { CreateRoomDto } from './dto/create-room.dto';
import { UpdateRoomDto } from './dto/update-room.dto';

// Interfejs dla użytkownika z MongoDB
interface UserWithId {
  _id: Types.ObjectId | string;
  username?: string;
  email?: string;
}

@Injectable()
export class RoomsService {
  constructor(@InjectModel(Room.name) private roomModel: Model<RoomDocument>) {}

  // Tworzenie pokoju
  async create(
    createRoomDto: CreateRoomDto,
    userId: string,
  ): Promise<RoomDocument> {
    const createdRoom = new this.roomModel({
      ...createRoomDto,
      createdBy: userId,
      createdAt: Date.now(),
    });
    return createdRoom.save();
  }

  // Lista wszystkich pokoi
  async findAll(): Promise<RoomDocument[]> {
    return this.roomModel
      .find()
      .populate('createdBy', 'username email')
      .populate('reservedBy', 'username email')
      .sort({ _id: -1 })
      .exec();
  }

  // Szczegóły pokoju
  async findOne(id: string): Promise<RoomDocument> {
    const room = await this.roomModel
      .findById(id)
      .populate('createdBy', 'username email')
      .populate('reservedBy', 'username email')
      .exec();

    if (!room) {
      throw new NotFoundException('Room not found');
    }

    return room;
  }

  // Aktualizacja pokoju (tylko właściciel)
  async update(
    id: string,
    updateRoomDto: UpdateRoomDto,
    userId: string,
  ): Promise<RoomDocument> {
    const room = await this.findOne(id);
    const createdBy = room.createdBy as unknown as UserWithId;

    if (createdBy._id.toString() !== userId) {
      throw new ForbiddenException('You can only update your own rooms');
    }

    Object.assign(room, updateRoomDto);
    return room.save();
  }

  // Usunięcie pokoju (tylko właściciel)
  async remove(id: string, userId: string): Promise<void> {
    const room = await this.findOne(id);
    const createdBy = room.createdBy as unknown as UserWithId;

    if (createdBy._id.toString() !== userId) {
      throw new ForbiddenException('You can only delete your own rooms');
    }

    await this.roomModel.deleteOne({ _id: id }).exec();
  }

// Reakcje like/dislike
async handleReaction(
  id: string,
  userId: string,
  type: 'like' | 'dislike',
): Promise<RoomDocument> {
  const room = await this.findOne(id);

  // Inicjalizacja tablic, jeśli nie istnieją
  if (!room.likedBy) room.likedBy = [];
  if (!room.dislikedBy) room.dislikedBy = [];

  // Konwertuj tablice na stringi dla łatwiejszego porównania
  const likedByIds = room.likedBy.map((user) =>
    typeof user === 'string' ? user : (user as any)._id.toString(),
  );

  const dislikedByIds = room.dislikedBy.map((user) =>
    typeof user === 'string' ? user : (user as any)._id.toString(),
  );

  const liked = likedByIds.includes(userId);
  const disliked = dislikedByIds.includes(userId);

  if (type === 'like') {
    if (liked) {
      throw new BadRequestException('You already liked this room');
    }

    // Dodaj userId do likedBy
    room.likedBy.push(userId as any);
    room.likes = (room.likes || 0) + 1;

    if (disliked) {
      // Usuń userId z dislikedBy
      room.dislikedBy = room.dislikedBy.filter((user) =>
        typeof user === 'string'
          ? user !== userId
          : (user as any)._id.toString() !== userId,
      );
      if (room.dislikes > 0) room.dislikes--;
    }
  } else if (type === 'dislike') {
    if (disliked) {
      throw new BadRequestException('You already disliked this room');
    }

    // Dodaj userId do dislikedBy
    room.dislikedBy.push(userId as any);
    room.dislikes = (room.dislikes || 0) + 1;

    if (liked) {
      // Usuń userId z likedBy
      room.likedBy = room.likedBy.filter((user) =>
        typeof user === 'string'
          ? user !== userId
          : (user as any)._id.toString() !== userId,
      );
      if (room.likes > 0) room.likes--;
    }
  }

  return room.save();
}


  // Rezerwacja pokoju
  async reserveRoom(id: string, userId: string): Promise<RoomDocument> {
    const room = await this.findOne(id);

    // Bezpieczne porównanie ID twórcy pokoju
    const createdById =
      typeof room.createdBy === 'string'
        ? room.createdBy
        : (room.createdBy as any)._id.toString();

    if (createdById === userId) {
      throw new ForbiddenException('You cannot reserve your own room');
    }

    if (room.reserved) {
      throw new ConflictException('Room already reserved');
    }

    room.reservedBy = userId as any;
    room.reserved = true;

    return room.save();
  }
}
